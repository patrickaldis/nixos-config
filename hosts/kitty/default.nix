{
  modules = [

    {
      age.init = keys: /* sh */ ''
        install -D -m 600 ${keys}/kitty /etc/ssh/ssh_host_ed25519_key
        install -D -m 644 ${keys}/kitty.pub /etc/ssh/ssh_host_ed25519_key.pub
      '';
    }

    ({ system, ... }: {
      nixpkgs.hostPlatform = system;
      system.stateVersion = "26.05";
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
    })

    ({ import-tree, ... }: { imports = [ (import-tree ./import-tree) ]; })
  ];
}
