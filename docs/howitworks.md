# How it works

## Components

Kaweezle is composed of the following projects/components:

- [kaweezle-rootfs](https://github.com/kaweezle/kaweezle-rootfs): A Modified
  Alpine mini root filesystem containing the packages needed to run kubernetes.
- [iknite](https://github.com/kaweezle/iknite): A golang based CLI managing the
  configuration and start of the kubernetes cluster.
- [kaweelze](https://github.com/kaweezle/kaweezle): A golang based Windows CLI
  that manages the lifecycle of the WSL distribution.
- [scoop-bucket](https://github.com/kaweezle/scoop-bucket): A
  [scoop](https://scoop.sh/) bucket for installing and updating kaweezle.

### The root filesystem

The root filesystem is based on the Alpine mini-rootfs
([Alpine downloads](https://alpinelinux.org/downloads/)). As of this writing,
the current version is 3.15 and available
[here](https://dl-cdn.alpinelinux.org/alpine/v3.15/releases/x86_64/alpine-minirootfs-3.15.0-x86_64.tar.gz).

As such, the root filesystem provides a minimal wsl distribution, containing
`busybox`, `musl` and `apk`.

Needed packages are added to the root filesystem. Most of them are dependencies
of `iknite` (see below) and are located in the
[edge](https://wiki.alpinelinux.org/wiki/Edge) packages repository. `Zsh` and
`oh-my-zsh` are added as a convenience.

The container images used by Kubernetes when starting are _pre-provisioned_
inside the container storage. It reduces startup time by avoiding the download
of the images.

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

All this tasks are performed in the
[Makefile](https://github.com/kaweezle/kaweezle-rootfs/blob/main/Makefile#L63)

### iknite

The [`iknite`](https://github.com/kaweezle/iknite) command performs the
configuration and start of the cluster. It is a golang based cli.

It is packaged and released with [goreleaser](https://goreleaser.com/) that
generates an APK.

The `iknite` apk pulls the following dependencies:

- `cri-o` is the container runtime
- `kubelet` is the kubernetes node agent
- `kubeadm` is the command that manages the cluster initialization
- `kubectl` is the main kubernetes command
- `kubelet-openrc` contains the kubelet startup files
- `cri-o-contrib-cni` contains the CRIO CNI configuration.
- `git` is used by `kustomize` (via `kubectl`) to fetch base services deployment
  yaml files from github.
- `util-linux-misc` contains tools used to manage images.

### Kaweezle

[`kaweezle`](https://github.com/kaweezle/kaweezle) is a golang based windows CLI
wrapping the calls to the WSL API and `wsl.exe` command. It also calls the
`iknite` command inside the WSL distribution to spawn or restart the cluster.

It also downloads and updates the root filesystem from github and updates the
local kubeconfig (in `$HOME\.kube\config`) with the appropriate configuration.
