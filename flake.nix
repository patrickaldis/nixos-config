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
  };

  outputs =
    {
      self,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      builder = { name, storeContents } : inputs.nixpkgs.lib.nixosSystem (
        import ./hosts/${name}
        // {
          specialArgs = {
            inherit storeContents;
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
                "nvim"
                "import-tree"
                "home-manager"
              ]
          );
        }
      );

      systems = [ "kitty" "elizabeth"];

      mkSystem = name: (builder {inherit name; storeContents = [];});
      mkInstaller = name: (builder {name = "lydia"; storeContents = [ (mkSystem name).config.system.build.toplevel ];});
      genSystemsWith = f: builtins.listToAttrs (map (name: {inherit name; value = f name;}) systems);

      pkgs = import inputs.nixpkgs { inherit system; };
    in
    {
      devShells.x86_64-linux.default = pkgs.mkShell {
        buildInputs = [ 
          inputs.agenix.packages.${system}.agenix
        ];
      };
      packages.${system}.mkInstallerFor = genSystemsWith (name: pkgs.writeShellApplication {
        name = "Generate an installable ISO";
        runtimeInputs = with pkgs; [age xorriso];
        text = ''
          # Decrypt keys to temp files
          TMPDIR=$(mktemp -d)
          trap 'rm -rf $TMPDIR' EXIT

          echo "Decrypting keys..."
          age -d -i ~/.ssh/id_ed25519 secrets/keys/prv/lydia.age > "$TMPDIR/lydia"
          age -d -i ~/.ssh/id_ed25519 secrets/keys/prv/root_lydia.age > "$TMPDIR/root_lydia"
          cp secrets/keys/pub/lydia.pub "$TMPDIR/lydia.pub"
          cp secrets/keys/pub/root_lydia.pub "$TMPDIR/root_lydia.pub"

          # Copy ISO and make writable
          ISO_SRC="$(ls ${(mkInstaller name).config.system.build.isoImage}/iso/*.iso)"
          ISO_OUT="installer.iso"

          echo "Adding keys to ISO..."
          cp "$ISO_SRC" "$ISO_OUT"
          chmod +w "$ISO_OUT"

          # Add keys to ISO
          xorriso -indev "$ISO_OUT" -outdev "$ISO_OUT" \
            -map "$TMPDIR/lydia" /lydia \
            -map "$TMPDIR/lydia.pub" /lydia.pub \
            -map "$TMPDIR/root_lydia" /root_lydia \
            -map "$TMPDIR/root_lydia.pub" /root_lydia.pub \
            -boot_image any replay \
            2>/dev/null

          echo "Done: $ISO_OUT"
        '';
      });
      nixosConfigurations = (genSystemsWith mkSystem) ;
    };
}
