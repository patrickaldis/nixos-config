#! /run/current-system/sw/bin/bash
type="rsa"
nix-shell -p openssh --command "ssh-keygen -f /etc/ssh/ssh_initrd__host_${type}_key -t ${type}"
