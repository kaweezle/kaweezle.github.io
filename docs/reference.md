# Command Reference

```powershell
> kaweezle --help
Manages a local kubernetes cluster working on WSL2.

Usage:
  kaweezle [command]

Examples:
kaweezle install
kaweezle status
kaweezle -v debug start


Available Commands:
  completion  Generate the autocompletion script for the specified shell
  help        Help about any command
  install     Install Kaweezle distribution
  start       Start the cluster
  status      Current status of the cluster
  stop        Stop the cluster and the WSL distribution
  uninstall   Uninstall the distribution
  update      Update the root file system

Flags:
      --config string      config file (default is $HOME/.kaweezle.yaml)
  -h, --help               help for kaweezle
      --json               Output JSON logs
  -l, --logfile string     Log file to save
  -n, --name string        The name of the WSL distribution to manage (default "kaweezle")
  -v, --verbosity string   Log level (debug, info, warn, error, fatal, panic) (default "info")
      --version            version for kaweezle

Use "kaweezle [command] --help" for more information about a command.
```

## Global flags

### --name <em>&lt;distribution_name&gt;</em>

By default, the name of the WSL distribution, the cluster and context is
`kaweezle`. You can use this option to use another name.

<!-- prettier-ignore-start -->
> [!NOTE]
> To avoid typing `--name xxx` on each command, you can create a 
> `$HOME\.kaweezle` file with `name: xxx` as context (see 
> [below](#configuration-file)).
<!-- prettier-ignore-end -->

### --json

Outputs the logs in JSON format. By using this option, no more pretty printing
is done.

### --logfile <em>&lt;log_filename&gt;</em>

Saves the logs in the specified file. This options disables pretty printing. If
the `--json` command is also specified, saves the log in JSON format.

### --verbosity <em>&lt;level&gt;</em>

Changes the verbosity level. The default verbosity level is `info`.

## Configuration file

You can create a file named `kaweezle` in your home directory (`$HOME` variable)
with global flags. For instance:

```yaml
name: k8dev
verbosity: debug
json: true
```

## Commands

### install

This command installs the WSL distribution and starts the cluster.

!> This commandd is outdated. Please use the [start](#start) command.

### start

This is the main command. This is **the** command to start the cluster.

It performs each of the following operations **if appropriate**:

- Download the last Kaweezle distribution root filesystem.
- Create the `kaweezle` distribution.
- Run the `/sbin/iknite start` command inside the distribution to start the
  cluster.
- Retrieve the kubeconfig of the cluster and integrate it in the local
  kubeconfig.
- Wait for the cluster pods to be initialized.

### status

The `status` command gives the status of the cluster. Example:

```powershell
❯ kaweezle status
🚀 Cluster kaweezle is started.
🚀 Pods status
└  active=12 stopped=0 unready=0
```

### stop

The `stop` command stops the WSL distribution, hence the cluster. It is
equivalent to running the following command:

```powershell
❯ wsl --terminate kaweezle
```

If the kubernetes cluster is running, it is stopped immediately.

### uninstall

The `uninstall` command uninstalls the WSL distribution. It is equivalent to
running the following command:

```powershell
❯ wsl --unregister kaweezle
```

It also removes the `kaweezle` context from the local kubeconfig, located in
`$env:USERPROFILE\.kube\config`.

### update

The `update` command updates the local copy of the WSL distribution root
filesystem, that is located in `$env:APPLOCALDATA\kaweezle`.

It downloads the root filesystem only if the local copy is different from the
last released version.

!> This command doesn't update the current WSL distribution.
