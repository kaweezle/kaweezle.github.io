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
