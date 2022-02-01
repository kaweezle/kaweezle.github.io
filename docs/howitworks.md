# How it works

## Introduction

The following diagram shows how Kaweezle is structured:

![architecture](_assets/arch.svg?style=centerme)

## Components

Kaweezle is composed of the following projects/components:

- [kaweezle-rootfs](https://github.com/kaweezle/kaweezle-rootfs): A Modified
  Alpine mini root filesystem containing the packages needed to run kubernetes.
- [iknite](https://github.com/kaweezle/iknite): A golang based Linux CLI
  managing the configuration and start of the kubernetes cluster.
- [kaweelze](https://github.com/kaweezle/kaweezle): A golang based Windows CLI
  that manages the lifecycle of the WSL distribution.
- [scoop-bucket](https://github.com/kaweezle/scoop-bucket): A
  [scoop](https://scoop.sh/) bucket for installing and updating kaweezle.

### The root filesystem

The root filesystem is based on the Alpine mini-rootfs
([Alpine downloads](https://alpinelinux.org/downloads/)). As of this writing,
the current version is 3.15 and available
[here](https://dl-cdn.alpinelinux.org/alpine/v3.15/releases/x86_64/alpine-minirootfs-3.15.0-x86_64.tar.gz).

Unmodified, the root filesystem provides a minimal wsl distribution, containing
`busybox`, `musl` and `apk`.

The root filesystem build performed by the
[Makefile](https://github.com/kaweezle/kaweezle-rootfs/blob/main/Makefile#L63)
adds the needed packages to the root filesystem. Most of them are dependencies
of [iknite](https://github.com/kaweezle/iknite/blob/main/.goreleaser.yaml#L54).
and reside in the [edge](https://wiki.alpinelinux.org/wiki/Edge) packages
repository. `Zsh` and `oh-my-zsh` are added as a convenience.

As the main objective is to deploy kubernetes with the less customization
possible, we use the standard [`openrc`](https://wiki.gentoo.org/wiki/OpenRC)
scripts. OpenRC doesn't like not being run by init. In consequence, we use the
[chroot customization](https://wiki.gentoo.org/wiki/OpenRC#Chroot_support)
method of the documentation.

The container images used by Kubernetes are _pre-provisioned_ with
[skopeo](https://github.com/containers/skopeo) inside the container storage of
the root filesystem. It reduces startup time by avoiding the download of the
images.

The following is the list of pre-provisionned images.

```
docker.io/rancher/local-path-provisioner
docker.io/rancher/mirrored-flannelcni-flannel-cni-plugin
k8s.gcr.io/coredns/coredns
k8s.gcr.io/etcd
k8s.gcr.io/kube-apiserver
k8s.gcr.io/kube-controller-manager
k8s.gcr.io/kube-proxy
k8s.gcr.io/kube-scheduler
k8s.gcr.io/metrics-server/metrics-server
k8s.gcr.io/pause
quay.io/coreos/flannel
quay.io/metallb/controller
quay.io/metallb/speaker
```

### iknite

The [`iknite`](https://github.com/kaweezle/iknite) command performs the
configuration and start of the cluster. It is a golang based cli.

It is packaged and released with [goreleaser](https://goreleaser.com/) that
generates an APK.

The `iknite` apk pulls the following dependencies:

- `cri-o` is the container runtime
- `kubelet` is the kubernetes node agent
- `kubeadm` is the command that manages the cluster initialization
- `kubectl` is the main kubernetes client
- `cri-o-contrib-cni` contains the CRIO CNI configuration files.
- `git` is used by `kustomize` (via `kubectl`) to fetch base services deployment
  yaml files from github.
- `util-linux-misc` contains tools used to manage images.

Having openrc installed will automatically pull `kubelet-openrc` and
`cri-o-openrc` by auto install rules.

`iknite` has currently only one command, `start`, that performs all the
operations to obtain a working cluster. The possible operations are:

- Starting OpenRC if it's not started;
- Deleting the cluster certificates if the IP address of the WSL Linux VM has
  changed (see [here](limitations.md#starting-after-reboot));
- Running kubeadm if needed to bootstrap the cluster or renew the certificates;
- Waiting for the cluster to be ready;
- Running kustomize with the infrastructure minimal infrastructure payloads:
  - [metal-lb](https://metallb.universe.tf/) to enable load balanced services,
  - [local path provisionner](https://github.com/rancher/local-path-provisioner)
    To be able to create PVCs,
  - [flannel](https://github.com/flannel-io/flannel) for pod routing.
  - [metrics-server](https://github.com/kubernetes-sigs/metrics-server) to
    enable default metrics.
- Installation of the kube config file for the `root` user.

### Kaweezle

[`kaweezle`](https://github.com/kaweezle/kaweezle) is a golang based windows CLI
wrapping the calls to the WSL API and the `wsl.exe` command. It also calls the
`iknite` command inside the WSL distribution to spawn or restart the cluster.

It also downloads and updates the root filesystem from github and updates the
local kubeconfig (in `$HOME\.kube\config`) with the appropriate configuration.

## Doing kaweezle manually

The following script shows how to perform what does kaweezle manually:

```powershell
# Create directory for environment
> mkdir kwsl
> cd kwsl
# Download the root filesystem
> [System.Net.WebClient]::new().DownloadFile("https://github.com/kaweezle/kaweezle-rootfs/releases/download/latest/rootfs.tar.gz","$PWD\rootfs.tar.gz")
# Create the WSL distribution
> wsl --import kwsl . rootfs.tar.gz
# Run it
> wsl -d kwsl
# Run iknite to start the cluster
➜  kwsl /sbin/iknite --name kwsl -v info start
INFO[0000] Starting openrc...
INFO[0002] Running/usr/bin/kubeadm init --apiserver-advertise-address=172.19.177.119 --kubernetes-version=1.23.1 --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=DirAvailable--var-lib-etcd,Swap --skip-phases=mark-control-plane...
INFO[0014] Apply base kustomization...
INFO[0016] executed
# Verify the cluster is running
➜  kwsl kubectl get pods --all-namespaces
NAMESPACE            NAME                                      READY   STATUS    RESTARTS   AGE
kube-system          coredns-64897985d-fvns2                   1/1     Running   0          39s
kube-system          coredns-64897985d-vbqmb                   1/1     Running   0          39s
kube-system          etcd-laptop-vkhdd5jr                      1/1     Running   0          56s
kube-system          kube-apiserver-laptop-vkhdd5jr            1/1     Running   0          56s
kube-system          kube-controller-manager-laptop-vkhdd5jr   1/1     Running   0          50s
kube-system          kube-flannel-ds-p9x5m                     1/1     Running   0          40s
kube-system          kube-proxy-8zd5b                          1/1     Running   0          40s
kube-system          kube-scheduler-laptop-vkhdd5jr            1/1     Running   0          56s
kube-system          metrics-server-7678c8c948-mv8bz           1/1     Running   0          39s
local-path-storage   local-path-provisioner-566b877b9c-qwq2c   1/1     Running   0          39s
metallb-system       controller-7cf77c64fb-nwpmd               1/1     Running   0          39s
metallb-system       speaker-22k7k                             1/1     Running   0          40s
# Return to windows
➜  kwsl exit
# Merge new cluster with existing configuration
>  powershell.exe -Command { $env:KUBECONFIG="$HOME\.kube\config;\\wsl$\kwsl\root\.kube\config"; kubectl config view --flatten > "$HOME\.kube\config.new"; mv -force "$HOME\.kube\config.new" "$HOME\.kube\config" }
# Selecting new cluster
> kubectx kwsl
# Getting nodes
> kubectl get nodes
NAME              STATUS   ROLES    AGE   VERSION
laptop-vkhdd5jr   Ready    <none>   17m   v1.23.3
# List WSL distributions
> wsl -l -v
  NAME                    STATE           VERSION
* Arch                    Stopped         2
  kwsl                    Running         2
```
