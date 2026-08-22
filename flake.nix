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
              ]
          );
        }
      );

      systems = [ "kitty" ];

      mkSystem = name: (builder {inherit name; storeContents = [];});
      mkInstaller = name: (builder {name = "lydia"; storeContents = [ (mkSystem name).config.system.build.toplevel ];});
      genSystemsWith = f: builtins.listToAttrs (map (name: {inherit name; value = f name;}) systems);

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
      nixosConfigurations = (genSystemsWith mkSystem) // { installers = genSystemsWith mkInstaller; } ;
    };
}
