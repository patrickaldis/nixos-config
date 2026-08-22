{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    nvim.url = "github:patrickaldis/nvim-config";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    import-tree.url = "github:denful/import-tree";
  };

  outputs =
    {
      self,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      magic-box = inputs.nixpkgs.lib.nixosSystem (
        import ./modules
        // {
          specialArgs = {
            system = "x86_64-linux";
            secrets = ./secrets;
          }
          // builtins.listToAttrs (
            map
              (name: {
                inherit name;
                value = inputs.${name};
              })
              [
                "disko"
                "agenix"
                "import-tree"
              ]
          );
        }
      );

      target = magic-box.config.system.build.toplevel;
      pkgs = import inputs.nixpkgs { inherit system; };
    in
    {
      devShells.x86_64-linux.default = pkgs.mkShell {
        buildInputs = [ 
          inputs.agenix.packages.${system}.agenix
          pkgs.age
          pkgs.xorriso
        ];
      };
      nixosConfigurations.magic-box = magic-box;
      nixosConfigurations.installer = inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; secrets = ./secrets; };
        modules = [
          "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ({ lib, ... }: {
            users.users.root.openssh.authorizedKeys.keys = (import ./secrets/secrets.nix).all.publicKeys;
            isoImage.storeContents = [ target ];
            system.extraDependencies = [
              target
              inputs.nixpkgs.outPath
              inputs.disko.outPath
            ];
            environment.systemPackages = [
              inputs.disko.packages.${system}.disko
              inputs.nvim.packages.${system}.default
            ];
            environment.etc."nixos-config".source = self;
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
              deps = [];
            };
            system.activationScripts.agenixNewGeneration.deps = lib.mkAfter [ "installSshKey" ];
          })
          ({ config, secrets, lib, ... }: {
            imports = [ inputs.agenix.nixosModules.default ];
            age.secrets.wifi = {
              file = "${secrets}/wifi.age";
              mode = "0440";
              group = "wpa_supplicant";
            };
            networking.networkmanager.enable = lib.mkForce false;
            networking.wireless = {
              enable = true;
              secretsFile = config.age.secrets.wifi.path;
              networks = builtins.listToAttrs
              (map (name: { inherit name; value.pskRaw = "ext:PSK_${name}"; })
                [ "BTWholeHome-QXR" "Patricks iPhone"]);
            };
          })
          {
            virtualisation.vmVariant = {
              virtualisation = {
                memorySize = 2048;
                cores = 3;
              };
            };
          }
        ];
      };
    };
}
