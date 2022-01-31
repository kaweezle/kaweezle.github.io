# Introduction

Kaweezle enables you to run a development [Kubernetes](https://kubernetes.io/)
cluster on your Windows based development machine with
[Windows Subsystem for Linux 2](https://docs.microsoft.com/en-us/windows/wsl/).

It is similar to [Rancher Desktop](https://rancherdesktop.io/). However, it
installs a _Vanilla_ Kubernetes distribution instead of relying on
[K3S](https://k3s.io/). It is also spawned through a simple command line tool
and doesn't need to download a fat Electron client.

As it uses WSL 2, it runs inside the WSL Virtual machine and doesn't need a
separate one, like [minikube](https://minikube.sigs.k8s.io/). As such, it
consumes less resources.

The WSL distribution is based on Alpine Linux. It makes the root filesystem,
that includes the base containers (API server, coredns, kube-proxy, ...) lighter
than with other distributions (<500 Mbs). Destroying and starting a new cluster
is also faster.

The following animation shows the time it takes to spawn a full blown cluster:

[![asciicast](https://asciinema.org/a/461421.svg)](https://asciinema.org/a/461421)

## Rationale

The rationale behind Kaweezle is to get a development cluster _close enough_ to
what one would have in production. In a previous life I have worked with
numerous solutions:

- [k3s](https://k3s.io/) on docker (MacOS)
- k3s in a [xhyve](https://github.com/machyve/xhyve) VM (MacOS)
- k3s in a [hyperkit](https://github.com/moby/hyperkit) VM (MacOS)
- k3s in an Openstack (cloud based) VM.
- Vanilla Kubernetes in an Openstack VM.
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/) for integration
  testing

I found K3s great until I got into advanced stuff like CSI plugins or cloud
provider. It makes some opinionated choices, like removing some kubelet options
and adding infrastructure payloads, like traefik. All this may get in your way
at some point.

Using
[kubeadm](https://kubernetes.io/fr/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
is harder but has got easier over time. Some linux distributions, like Archlinux
and Alpine, are quite fast on releasing the new Kubernetes versions.

My usage of Kubernetes started before minikube and kind became the _de facto_
standards or even stable. Having control upon the cluster also makes it easier
to switch between local development and developing on a cloud based VM.

Having switched my development environment to Windows/WSL, I wanted to retrieve
what I had on MacOS. Kaweezle is my attempt for that.
