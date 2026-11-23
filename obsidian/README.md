## Obsidian Nixos Configuration

This repository provides the basic stuff you need in your nixos configuration to work with Obsidian's infrastructure.
To add it to your configuration, first clone the repo and copy into /etc/nixos/obsidian, e.g.:

```bash
git clone git@gitlab.com:obsidian.systems/nixos-configuration
sudo cp -r nixos-configuration /etc/nixos/obsidian
```

Once you've cloned the repository, you need to add a reference in /etc/nixos/configuration.nix.  It should looks something like this:

```nix
{ config, pkgs, ... }:
in {
  imports = [
    ./hardware-configuration.nix
    ./obsidian
  ];

  users.users.yourusername = {
    extraGroups = [ "wheel" ... more groups ... ];
    ... more user config ...
    NB: You must specify the rest of your user account information in this block. Otherwise, upon rebuild, your account will be replaced.
  };
... more nixos config ...
}
```

Finally, switch to the new configuration:

```bash
sudo nixos-rebuild switch
```

The obsidian module will generate an ssh key at `/etc/obsidian/ssh_deploy_key`. To allow nixbld users to access private O.S. repos, you must provide the repo admin the public key located at `/etc/obsidian/ssh_deploy_key.pub`.

## Add a new employee configuration

To use remote build machines, it is required that you are added as a user to the configuration. You can do that by adding `<username>.nix` to the `users/` directory.
Your username should be in the form "\<initials>\<lastname>", e.g. `jsmith` for "Jane Smith".

You then add a file with at least the following contents:
```nix
{
  openssh.authorizedKeys.keys = [
    "ssh-rsa ..." # can be multiple keys
  ];
  hashedPassword = "...";
}
```

They `authorizedKey.key` should be the public key generated via `ssh-keygen` from the [NixOS installation guide](https://gitlab.com/obsidian.systems/handbook/-/blob/master/NixOS.md#installation-and-configuration-instructions), and [`hashedPassword`](https://nixos.org/manual/nixos/stable/#sec-user-management) can be obtained by executing `mkpasswd -m sha-512`.

Note: There are other options that you can add to your `<username>.nix` as well, for example `shell` to set your default shell. In general, all options that are valid for `users.users.<name>` can be used.

Afterwards, don't forget to modify `users/default.nix` by adding your user to the `imports` section and the `obsidian.staff` attribute set.

## Obsidian Machines configuration

*N.B. the top-level default.nix module includes this step.
This is just for reference or for doing something more manual than the previous steps.*

To create aliases to the Obsidian servers' forwarded ports, add the following lines to /etc/nixos/configuration.nix:
```
{
  ... nix configuration goes here ...

  imports = [
    ./obsidian/machines.nix
  ];
}
```
This will create `*-remote` aliaes to the correct ports at `obsidian.webhop.org`.

Then, in your `~/.ssh/config` do something like:
```
# Obsidian

Host *-remote
  User my_user_name
  ForwardAgent yes

Host *.office
  User my_user_name
  ForwardAgent yes
```
The `*.office` is for a lower latency connection when behind the same router as the servers themselves (e.g. at the office).

## Obsidian Users Configuration

To create user accounts for Obsidian staff and consultants on shared/company computers, add the following lines to /etc/nixos/configuration.nix:
```
{
  ... nix configuration goes here ...

  users.extraGroups.wheel.members = [ /* users who should have wheel access */ ];

  imports = [
    ./obsidian/users
  ];
}
```
Note that this script will:
- create regular user accounts for the users specfied in users/default.nix
- automatically add ali and ryan to the "wheel" group
- add any users in "extraWheel" to the "wheel" group

## Stage1 SSH Access
To enable stage1 ssh access (so that you can enter decryption keys remotely), add the following to your nix configuration:
```
let authorizedKeys = [ authorized_ssh_keys_here ]; # Keys should be in double quotes
    stage1SSH = import ./stage1-ssh { inherit authorizedKeys; };
in {
  ... your nix configuration ...
  boot = {
    initrd = {
      kernelModules = [ kernel_module_for_network_device ]; # Module name should be in double quotes
      network = stage1SSH;
      ... the rest of your initrd config ...
    }
    ... the rest of your boot config ...
  };
}
```

To retrieve your kernel driver name, run `sudo lshw -C network`. The kernel driver name is visible in the "configuration" section of the resulting output. For example the driver name "atl1c" appears as follows in the output of lshw:

`configuration: autonegotiation=on broadcast=yes driver=atl1c driverversion=1.0.1.1-NAPI duplex=full ip=192.168.0.105 latency=0 link=yes multicast=yes port=twisted pair speed=1Gbit/s `

The script stage1-ssh/generate-key.sh will produce an RSA host key and place it in /etc/ssh.
