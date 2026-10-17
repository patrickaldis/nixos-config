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
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "home-manager";
    };
    virglrenderer = {
      url = "git+https://gitlab.freedesktop.org/virgl/virglrenderer.git";
      flake = false;
    };
  };

  outputs =
    {
      self,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      builder =
        { name, storeContents }:
        let
          hostConfig = import ./hosts/${name};
        in
        inputs.nixpkgs.lib.nixosSystem (
          hostConfig
          // {
            modules = hostConfig.modules ++ [ ({ import-tree, ... }: import-tree ./modules) ];
            specialArgs = {
              inherit storeContents;
              system = "x86_64-linux";
              secrets = ./secrets;
              allUserKeys = (import ./secrets/secrets.nix).allUsers.publicKeys;
              hostName = name;
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
                  "nvim"
                  "import-tree"
                  "home-manager"
                  "plasma-manager"
                  "virglrenderer"
                ]
            );
          }
        );

      systems = [
        "kitty"
        "elizabeth"
        "lydia"
      ];

      mkSystem =
        name:
        (builder {
          inherit name;
          storeContents = [ ];
        });
      mkInstaller =
        name:
        (builder {
          name = "lydia";
          storeContents = [ (mkSystem name).config.system.build.toplevel ];
        });
      genSystemsWith =
        f:
        builtins.listToAttrs (
          map (name: {
            inherit name;
            value = f name;
          }) systems
        );

      mkPayload =
        host: /* bash */ ''
          echo "Assembling payload for ${host}..."
          for file in ${./secrets/payload}/${host}/*; do
            base="$(basename "$file")"
            case "$base" in
              *.age) age -d -i "$IDENTITY" "$file" > "$PAYLOAD/''${base%.age}" ;;
              *) cp "$file" "$PAYLOAD/$base" ;;
            esac
          done
        '';

      pkgs = import inputs.nixpkgs { inherit system; };
    in
    {
      devShells.x86_64-linux.default = pkgs.mkShell {
        buildInputs = [
          inputs.agenix.packages.${system}.agenix
        ];
      };
      packages.${system} = {
        run-vm = genSystemsWith (
          name:
          pkgs.writeShellApplication {
            name = "${name} vm";
            runtimeInputs = (
              with pkgs;
              [
                age
              ]
            );
            text = ''

              PAYLOAD_DIR=$(mktemp -d)
              export PAYLOAD_DIR=$PAYLOAD_DIR
              export NIX_SWTPM_DIR
              NIX_SWTPM_DIR=$(mktemp -d)
              trap 'rm -rf "$PAYLOAD_DIR" "$NIX_SWTPM_DIR"' EXIT

              PAYLOAD="$PAYLOAD_DIR"
              IDENTITY="$HOME/.ssh/id_ed25519"
              ${mkPayload name}

              ${self.nixosConfigurations.${name}.config.system.build.vm}/bin/run-${name}-vm
            '';
          }
        );
        install = genSystemsWith (
          name:
          pkgs.writeShellApplication {
            name = "install ${name}";
            runtimeInputs =
              (with pkgs; [
                age
                nixos-install
              ])
              ++ [ inputs.disko.packages.${system}.default ];
            text = ''
              # Every step here needs root, so escalate once and stay there.
              # Re-exec on argument count, not on uid: the identity has to be
              # captured before escalating (root's ~ isn't ours), and keying
              # off the argument means this can never loop.
              if [ "$#" -eq 0 ]; then
                exec sudo "$0" "$HOME/.ssh/id_ed25519"
              fi
              IDENTITY="$1"
              if [ "$(id -u)" -ne 0 ]; then
                echo "$0: sudo did not give us root" >&2
                exit 1
              fi

              disko --mode disko --flake ${self}#${name}

              PAYLOAD=/mnt/payload
              install -d -m 700 "$PAYLOAD"
              ${mkPayload name}

              nixos-install --flake ${self}#${name} --no-root-passwd
            '';
          }
        );
        mkInstallerFor = genSystemsWith (
          name:
          pkgs.writeShellApplication {
            name = "${name} iso";
            runtimeInputs = with pkgs; [
              age
              xorriso
            ];
            text = ''
              PAYLOAD=$(mktemp -d)
              trap 'rm -rf "$PAYLOAD"' EXIT

              IDENTITY="$HOME/.ssh/id_ed25519"
              ${mkPayload "lydia"}

              # Copy ISO and make writable
              ISO_SRC="$(ls ${(mkInstaller name).config.system.build.isoImage}/iso/*.iso)"
              ISO_OUT="installer.iso"

              cp "$ISO_SRC" "$ISO_OUT"
              chmod +w "$ISO_OUT"

              # Add keys to ISO
              xorriso -indev "$ISO_OUT" -outdev "$ISO_OUT" \
                -map "$PAYLOAD" /payload \
                -boot_image any replay \
                2>/dev/null

              echo "Done: $ISO_OUT"
            '';
          }
        );
      };
      nixosConfigurations = (genSystemsWith mkSystem);
    };
}
