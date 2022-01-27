# Quick start

Be sure to ensure to have the [pre-requisites](/prerequisites) installed.

To install kaweezle, issue the following commands:

```powershell
> scoop bucket add kaweezle https://github.com/kaweezle/scoop-bucket
> scoop install kaweezle
```

Then you can spawn a cluster with the following command:

```powershell
> kaweezle start
```

This will perform the following operations:

- Check and download the latest version of the kaweezle distribution root
  filesystem.
- Create the `kaweezle` WSL distribution.
- Spawn the kubernetes cluster on the distribution.
- Wait for the cluster to be ready.
- Install the minimal workloads to have an actual working cluster.

The following animation shows a complete installation:

[![asciicast](https://asciinema.org/a/461421.svg)](https://asciinema.org/a/461421)
