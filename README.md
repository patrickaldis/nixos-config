# Setup

1. `ssh-keygen -t ed25519 -f ssh_host_ed25519_key -N ""`
2. Add key to `secrets.nix` and run `sudo sh ./set-key-perms.sh .`
3. Rekey all secrets
4. `nix build .#nixosConfiguration.runner-server.config.system.build.image`
5. Flash resulting ISO to USB, transferring ssh keys to usb
6. `sudo disko --mode disko --flake /etc/nixos-config#runner-server`
7. `sudo nixos-install --flake /etc/nixos-config#runner-server`
8. Copy ssh keys to new machine under /etc/ssh/ssh_host_ed25519_key*

# Github Setup
1. Fetch PAT from [here](https://github.com/settings/tokens)
2. Add contents to `runner-token.age` via `agenix -e runner-token.age`
