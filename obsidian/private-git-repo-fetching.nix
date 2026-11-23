{ config, options, pkgs, ... }:

{

  nix = {
    settings.extra-sandbox-paths = [
      "/etc/obsidian/ssh_deploy_key_config"
      "/etc/obsidian/ssh_deploy_key"
    ];
    nixPath = options.nix.nixPath.default ++ [
      "ssh-config-file=/etc/obsidian/ssh_deploy_key_config"
    ];
  };

  environment.etc."obsidian/ssh_deploy_key_config" = {
    text = ''
      Host github.com
        IdentityFile /etc/obsidian/ssh_deploy_key
        StrictHostKeyChecking=no
        UserKnownHostsFile=/dev/null

      Host gitlab.com
        IdentityFile /etc/obsidian/ssh_deploy_key
        StrictHostKeyChecking=no
        UserKnownHostsFile=/dev/null

      Host code.obsidian.systems
        IdentityFile /etc/obsidian/ssh_deploy_key
        StrictHostKeyChecking=no
        UserKnownHostsFile=/dev/null
    '';
    mode = "0440";
    group = "nixbld";
  };

  system.activationScripts = {
    obsidianSSH = {
      text = ''
        if [ ! -f /etc/obsidian/ssh_deploy_key ]; then
          mkdir -p /etc/obsidian
          ${pkgs.openssh}/bin/ssh-keygen -t rsa -N "" -f /etc/obsidian/ssh_deploy_key
          chgrp nixbld /etc/obsidian/ssh_deploy_key
          chgrp nixbld /etc/obsidian/ssh_deploy_key.pub
          chmod g+r /etc/obsidian/ssh_deploy_key
        fi
      '';
      deps = [];
    };
  };

}
