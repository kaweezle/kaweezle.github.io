# Limitations & Bugs

## Only one cluster at a time

Currently there can be only one cluster running at a time. You can create
multiple kaweezle distrbutions, but because the first one is going to create a
CNI network interface, others would fail on the same task.

It is also the case if you are running Rancher desktop, at it also uses a CNI
interface.

## Starting after reboot

The WSL Linux VM changes its IP address after each reboot. Because kubeadm
creates certificates with the IP address as alternative names, one cannot just
start the kubelet service to restore the cluster.

To work around this, iknite detects the interface IP address change and relaunch
kubeadm after having deleted the existing certificates to re-create them,
keeping only the CA self signed certificate created during the first launch.

This slows down a little bit the restart after a shutdown.
