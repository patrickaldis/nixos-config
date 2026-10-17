{
  modules = [
    (
      { lib, config, pkgs, modulesPath, system, agenix, disko, nvim, secrets, storeContents, allUserKeys, ... }:
      {
        imports = [
          "${modulesPath}/installer/cd-dvd/iso-image.nix"
          agenix.nixosModules.default
        ];

        nixpkgs.hostPlatform = system;
        system.stateVersion = "26.05";
        age.secrets.wifi = {
          file = "${secrets}/wifi.age";
          mode = "0440";
          group = "wpa_supplicant";
        };
        age.secrets.root-pass.file = "${secrets}/root-pass.age";
        users.users.patrick = {
          isNormalUser = true;
          hashedPasswordFile = config.age.secrets.root-pass.path;
          extraGroups = [ "wheel" ];
        };
        services.getty = {
          extraArgs = [ "--skip-login" ];
          loginOptions = "-- patrick";
          helpLine = lib.mkForce "";
          greetingLine = lib.mkForce "<< NixOS Installer >>";
        };
        # Drop the blank line the default /etc/issue template leaves before the
        # (now-skipped) login prompt, so "Password:" sits right under the banner.
        # (Same ANSI bold-green wrapping as upstream's default issue template.)
        environment.etc.issue = lib.mkForce {
          source = pkgs.writeText "issue" ''
            [1;32m${config.services.getty.greetingLine}[0m
          '';
        };
        networking.networkmanager.enable = lib.mkForce false;
        networking.wireless = {
          enable = true;
          secretsFile = config.age.secrets.wifi.path;
          networks = builtins.listToAttrs (
            map
              (name: {
                inherit name;
                value.pskRaw = "ext:PSK_${name}";
              })
              [
                "BTWholeHome-QXR"
                "Patricks iPhone"
              ]
          );
        };
        users.users.root.openssh.authorizedKeys.keys = allUserKeys;
        isoImage.storeContents = storeContents;
        system.extraDependencies = storeContents;
        environment.systemPackages = [
          disko.packages.${system}.disko
          nvim.packages.${system}.default
          pkgs.git
        ];
        services.openssh = {
          enable = true;
          settings.PermitRootLogin = "prohibit-password";
        };
        # Pinned so the unattended clone doesn't trip StrictHostKeyChecking.
        programs.ssh.knownHosts.github = {
          hostNames = [
            "github.com"
            "ssh.github.com"
          ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
        };

        # Clone the config into patrick's home once the network is up. The key
        # this authenticates with is installed during activation by age.initUser.
        systemd.services.clone-nixos-config = {
          description = "Clone nixos-config into patrick's home directory";
          wantedBy = [ "multi-user.target" ];
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];
          path = [
            pkgs.git
            pkgs.openssh
          ];
          unitConfig.ConditionPathExists = [
            "/home/patrick/.ssh/id_ed25519"
            "!/home/patrick/nixos-config"
          ];
          serviceConfig = {
            Type = "oneshot";
            User = "patrick";
            Group = "users";
            WorkingDirectory = "/home/patrick";
            Environment = "HOME=/home/patrick";
            # Wireless may not have associated on the first attempt.
            Restart = "on-failure";
            RestartSec = 10;
          };
          script = /* bash */ ''
            git clone git@github.com:patrickaldis/nixos-config.git
          '';
        };

        services.avahi = {
          enable = true;
          publish = {
            enable = true;
            addresses = true;
          };
        };

        age.init = pl: /* bash */ ''
          install -D -m 600 ${pl}/lydia /etc/ssh/ssh_host_ed25519_key
          install -D -m 644 ${pl}/lydia.pub /etc/ssh/ssh_host_ed25519_key.pub
          install -D -m 600 ${pl}/root_lydia /root/.ssh/id_ed25519
          install -D -m 644 ${pl}/root_lydia.pub /root/.ssh/id_ed25519.pub
        '';

        age.initUser = pl: /* bash */ ''
          install -d -m 700 -o patrick -g users /home/patrick/.ssh
          install -m 600 -o patrick -g users ${pl}/patrick_lydia /home/patrick/.ssh/id_ed25519
          install -m 644 -o patrick -g users ${pl}/patrick_lydia.pub /home/patrick/.ssh/id_ed25519.pub
        '';

        # Make bootable
        hardware.enableAllHardware = true;
        isoImage = {
          makeEfiBootable = true;
          makeUsbBootable = true;
        };
        boot.loader.grub.memtest86.enable = false;

        swapDevices = lib.mkImageMediaOverride [ ];
        fileSystems = lib.mkImageMediaOverride config.lib.isoFileSystems;
        boot.initrd.luks.devices = lib.mkImageMediaOverride { };

        system.activationScripts.linkPayload.text = /* bash */ "ln -sfn /iso/payload /payload";
        system.activationScripts.installSshKey.deps = [ "linkPayload" ];
      }
    )
  ];
}
