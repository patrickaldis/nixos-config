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
        services.avahi = {
          enable = true;
          publish = {
            enable = true;
            addresses = true;
          };
        };

        age.init = keys: /* bash */ ''
          install -D -m 600 ${keys}/lydia /etc/ssh/ssh_host_ed25519_key
          install -D -m 644 ${keys}/lydia.pub /etc/ssh/ssh_host_ed25519_key.pub
          install -D -m 600 ${keys}/root_lydia /root/.ssh/id_ed25519
          install -D -m 644 ${keys}/root_lydia.pub /root/.ssh/id_ed25519.pub
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
