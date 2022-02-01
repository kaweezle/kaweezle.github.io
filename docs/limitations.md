# Limitations & Known Bugs

Current issues are registered on the
[kaweezle project](https://github.com/kaweezle/kaweezle/issues?q=is%3Aissue+is%3Aopen+label%3Abug).

## Only one cluster at a time

Currently there can be only one cluster running at a time. You can create
multiple kaweezle distrbutions, but because the first one is going to create a
CNI network interface, others would fail on the same task.

It is also the case if you are running Rancher desktop, at it also uses a CNI
interface.

## Slow start

The WSL Linux VM changes its IP address after each reboot. Because kubeadm
creates certificates with the IP address as alternative names, one cannot just
start the kubelet service to restore the cluster.

To work around this, iknite detects the interface IP address change and relaunch
kubeadm after having deleted the existing certificates to re-create them,
keeping only the CA self signed certificate created during the first launch.
This slows down a little bit the restart after a shutdown.

An option allows using a DNS name instead of an IP address. However, the IP
address is still used in the configuration of some infrastructure deployments.

## Missing backup and update

It is currently not possible to backup the cluster configuration and data. There
is also no automated way of upgrading the cluster. However, as the cluster is a
standard kubeadm cluster, it should be possible to follow the
[standard documentation](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)
after running `apk --update upgrade`.
