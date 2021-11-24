# Unattended VM Installer

This program provides a way to perform a fully-automated,
noninteractive installation of certain Linux distributions onto
virtual machines using virt-install.

## Installation

No installation necessary. Just have
[ruby](https://www.ruby-lang.org/) and
[virt-install](https://virt-manager.org/) installed. Also,
[cloud-image-utils](https://tracker.debian.org/pkg/cloud-utils) is
needed for `cloud-localds` to generate the ISO 9660 image containing
the autoinstall configuration used by [Ubuntu
Server's](https://ubuntu.com/server) installer,
[subiquity](https://github.com/CanonicalLtd/subiquity).

## Usage

The `--help` output:

    Usage: vm-install [options] PRESET
    Install a new virtual machine (using virt-install(1)).

        -n, --name=NAME                  Name to call the new VM; default: same as PRESET
        -c, --config=CONFIG              config file to use; default: vm-install.yaml in the current directory
        -h, --help                       Show this help and exit
        -V, --version                    Output version information and exit

The "presets" are just predefined `virt-install` options. Presets are
defined in a YAML configuration file, called `vm-install.yaml` by
default.

<!--
Local Variables:
coding: utf-8
End:
-->
