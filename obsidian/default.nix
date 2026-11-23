{ config, pkgs, lib, ... }:

{

  imports = [
    ./cache.nix
    ./machines.nix
    ./private-git-repo-fetching.nix
  ];

  services = {
    printing.drivers = lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      # (pkgs.callPackage_i686 ./hl3170cdw {})
    ];
  };

  nix = {
    settings.sandbox = true;
  };

}
