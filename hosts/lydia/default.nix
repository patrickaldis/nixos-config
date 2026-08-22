{
  modules = [
    (
      { lib, config, modulesPath, system, agenix, disko, nvim, secrets, storeContents, ... }:
      {
        imports = [
          "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
          agenix.nixosModules.default
        ];

        nixpkgs.hostPlatform = system;
        system.stateVersion = "26.05";
        age.secrets.wifi = {
          file = "${secrets}/wifi.age";
          mode = "0440";
          group = "wpa_supplicant";
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
        users.users.root.openssh.authorizedKeys.keys = (import "${secrets}/secrets.nix").all.publicKeys;
        isoImage.storeContents = storeContents;
        system.extraDependencies = storeContents;
        environment.systemPackages = [
          disko.packages.${system}.disko
          nvim.packages.${system}.default
        ];
        nix.settings.experimental-features = [
          "nix-command"
          "flakes"
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
        networking.hostName = "lydia";

        system.activationScripts.installSshKey = {
          text = ''
            if [ -f /iso/lydia ] && [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
              install -D -m 600 /iso/lydia /etc/ssh/ssh_host_ed25519_key
              install -D -m 644 /iso/lydia.pub /etc/ssh/ssh_host_ed25519_key.pub
            fi
            if [ -f /iso/root_lydia ] && [ ! -f /root/.ssh/id_ed25519 ]; then
              install -D -m 600 /iso/root_lydia /root/.ssh/id_ed25519
              install -D -m 644 /iso/root_lydia.pub /root/.ssh/id_ed25519.pub
            fi
          '';
          deps = [ ];
        };
        system.activationScripts.agenixNewGeneration.deps = lib.mkAfter [ "installSshKey" ];
      }
    )
  ];
}
