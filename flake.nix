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

              for file in ${./secrets/keys/prv}/${name}/*; do
                age -d -i ~/.ssh/id_ed25519 "$file" > "$PAYLOAD_DIR/$(basename "''${file%.age}")"
              done

              for file in ${./secrets/keys/pub}/${name}/*; do
                cp "$file" "$PAYLOAD_DIR/$(basename "$file")"
              done

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
              sudo disko --mode disko --flake ${self}#${name}

              TARGETDIR=/mnt/payload

              mkdir "$TARGETDIR"

              echo "Decrypting private keys..."
              for file in ${./secrets/keys/prv}/${name}/*; do
                age -d -i ~/.ssh/id_ed25519 "$file" > "$TARGETDIR/$(basename "''${file%.age}")"
              done

              echo "Copying public keys..."
              for file in ${./secrets/keys/pub}/${name}/*; do
                cp "$file" "$TARGETDIR/$(basename "$file")"
              done

              sudo nixos-install --flake ${self}#${name} --no-root-passwd
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
              # Decrypt keys to temp files
              TMPDIR=$(mktemp -d)
              trap 'rm -rf "$TMPDIR"' EXIT

              age -d -i ~/.ssh/id_ed25519 secrets/keys/prv/lydia.age > "$TMPDIR/lydia"
              age -d -i ~/.ssh/id_ed25519 secrets/keys/prv/root_lydia.age > "$TMPDIR/root_lydia"
              cp secrets/keys/pub/lydia.pub "$TMPDIR/lydia.pub"
              cp secrets/keys/pub/root_lydia.pub "$TMPDIR/root_lydia.pub"

              # Copy ISO and make writable
              ISO_SRC="$(ls ${(mkInstaller name).config.system.build.isoImage}/iso/*.iso)"
              ISO_OUT="installer.iso"

              cp "$ISO_SRC" "$ISO_OUT"
              chmod +w "$ISO_OUT"

              # Add keys to ISO
              xorriso -indev "$ISO_OUT" -outdev "$ISO_OUT" \
                -mkdir /payload \
                -map "$TMPDIR/lydia" /payload/lydia \
                -map "$TMPDIR/lydia.pub" /payload/lydia.pub \
                -map "$TMPDIR/root_lydia" /payload/root_lydia \
                -map "$TMPDIR/root_lydia.pub" /payload/root_lydia.pub \
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
