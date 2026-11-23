{ config, lib, pkgs, ... }:

with lib;

let
  untrustedName = "nix_untrusted_proxy";

  userOpts = {
    options = {
      nix = mkOption {
        type = types.submodule {
          options = {
            remote-builder-proxy = mkOption {
              type = types.submodule {
                options = {
                  keys = mkOption {
                    type = types.listOf types.str;
                    default = [];
                    description = ''
                      A list of verbatim OpenSSH public keys that should be added to the nix
                      builder proxy acount on behalf of the user. Just like
                      <literal>openssh.authorizedKeys.keys</literal>.
                    '';
                  };

                  keyFiles = mkOption {
                    type = types.listOf types.path;
                    default = [];
                    description = ''
                      A list of files each containing one OpenSSH public key that should be
                      added to the nix builder proxy acount on behalf of the user. Just like
                      <literal>openssh.authorizedKeys.keyFiles</literal>.
                    '';
                  };
                };
              };
              default = { };
            };
          };
        };
        default = { };
      };
    };
  };

  otherUsers = map
   (u: u.nix.remote-builder-proxy)
   (attrValues (builtins.removeAttrs config.users.users [
     "nix_trusted_proxy" untrustedName
   ]));

in {

  ###### interface

  options = {
    users.users = mkOption {
      type = with types; attrsOf (submodule userOpts);
    };
  };


  ###### implementation

  config = {
    users.users.${untrustedName} = {
      shell = "/var/run/current-system/sw/bin/bash";

      openssh.authorizedKeys.keys = lib.concatMap (o: o.keys) otherUsers;
      openssh.authorizedKeys.keyFiles = lib.concatMap (o: o.keyFiles) otherUsers;
    };
  };
}
