# Pre-requisites

Kaweezle is better installed with [Scoop](https://scoop.sh/). You can install it
with the following command:

```powershell
> iwr -useb get.scoop.sh | iex
```

To run kaweezle, you'll need to have
[Window Subsystem for Linux installed](https://docs.microsoft.com/en-us/windows/wsl/).

The simplest way to install it is to run the following command:

```powershell
> wsl --install
```

After reboot, update the kernel and set the default version to version 2:

```powershell
> sudo wsl --update
> wsl --set-default-version 2
```

To use the kubernetes cluster, you will need to have
[kubectl](https://kubernetes.io/docs/tasks/tools/) installed:

```powershell
> scoop install kubectl
```

Other tools might be of insterest, like [`k9s`](https://k9scli.io/),
[`kubectx/kubens`](https://github.com/ahmetb/kubectx) or
[`stern`](https://github.com/wercker/stern). All are available through scoop.
You can install all of them at once with the following command:

```powershell
> scoop install k9s kubectx kubens stern
```
