#! /run/current-system/sw/bin/bash
nix-shell -p dropbear --command "dropbearkey -f /etc/ssh/ssh_dropbear_host_key -t rsa"
