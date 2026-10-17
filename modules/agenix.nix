{ agenix, config, lib, ... }:
let
  pl = "/payload";
in
{
  imports = [
    agenix.nixosModules.default
  ];

  options.age = {
    init = lib.mkOption {
      type = lib.types.functionTo lib.types.str;
      description = ''
        Initialisation script to set up keys, given the payload directory.
        Runs before agenix decrypts secrets, since age.identityPaths points at
        the host key this installs, so only host identities belong here.
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
        if [ -d ${pl} ]; then
          ${config.age.init pl}
        fi
      '';
      deps = [ ];
    };
    system.activationScripts.agenixNewGeneration.deps = lib.mkAfter [ "installSshKey" ];

    system.activationScripts.installUserSshKey = {
      text = /* sh */ ''
        if [ -d ${pl} ]; then
          :
          ${config.age.initUser pl}
        fi
      '';
      deps = [
        "installSshKey"
        "users"
      ];
    };

    system.activationScripts.removePayload = {
      text = /* sh */ "rm -rf ${pl}";
      deps = [ "installUserSshKey" ];
    };
  };
}
