{ agenix, config, lib, ... }:
{
  imports = [
    agenix.nixosModules.default
  ];

  options.age.init = lib.mkOption {
    type = lib.types.functionTo lib.types.str;
    description = "Initialisation script to set up keys";
  };

  config = {
    system.activationScripts.installSshKey = {
      text =
        let
          keys = "/payload";
        in
        /* sh */ ''
          if [ -d ${keys} ]; then
            ${config.age.init keys}
            rm -rf ${keys}
          fi
        '';
      deps = [ ];
    };
    system.activationScripts.agenixNewGeneration.deps = lib.mkAfter [ "installSshKey" ];
  };
}
