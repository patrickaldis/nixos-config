{
  modules = [

    ({ agenix, lib, ... }: {
      imports = [ agenix.nixosModules.default ];

      system.activationScripts.installSshKey = {
        text = let
          payload = "/payload";
        in /* bash */ ''
          if [ -d ${payload} ]; then
            install -D -m 600 ${payload}/kitty /etc/ssh/ssh_host_ed25519_key
            install -D -m 644 ${payload}/kitty.pub /etc/ssh/ssh_host_ed25519_key.pub
            rm -rf ${payload}
          fi
        '';
        deps = [ ];
      };
      system.activationScripts.agenixNewGeneration.deps = lib.mkAfter [ "installSshKey" ];
    })

    ({ system, ... }: {
      nixpkgs.hostPlatform = system;
      system.stateVersion = "26.05";
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      # enable flakes
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
    })

    ({ import-tree, ... }: { imports = [ (import-tree ./import-tree) ]; })
  ];
}
