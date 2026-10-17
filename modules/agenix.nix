{ agenix, config, lib, ... }:
let
  keys = "/payload";
in
{
  imports = [
    agenix.nixosModules.default
  ];

  options.age = {
    init = lib.mkOption {
      type = lib.types.functionTo lib.types.str;
      description = ''
        Initialisation script to set up keys. Runs before agenix decrypts
        secrets, since age.identityPaths points at the host key this installs,
        so only host identities belong here.
      '';
    };
    initUser = lib.mkOption {
      type = lib.types.functionTo lib.types.str;
      default = _: "";
      description = ''
        As age.init, but runs after the users activation script, so user
        accounts resolve by name and their home directories exist.
      '';
    };
  };

  config = {
    system.activationScripts.installSshKey = {
      text = /* sh */ ''
        if [ -d ${keys} ]; then
          ${config.age.init keys}
        fi
      '';
      deps = [ ];
    };
    system.activationScripts.agenixNewGeneration.deps = lib.mkAfter [ "installSshKey" ];

    system.activationScripts.installUserSshKey = {
      text = /* sh */ ''
        if [ -d ${keys} ]; then
          :
          ${config.age.initUser keys}
        fi
      '';
      deps = [
        "installSshKey"
        "users"
      ];
    };

    system.activationScripts.removePayload = {
      text = /* sh */ "rm -rf ${keys}";
      deps = [ "installUserSshKey" ];
    };
  };
}
