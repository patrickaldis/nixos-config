{ config, options, pkgs, lib, ... }:

let
  # TODO get from elsewhere
  hackGet = p:
    let pkgs = import <nixpkgs> {}; # Need to bootstrap to avoid infinite recursion.
        filterArgs = x: removeAttrs x [ "branch" ];
    in if builtins.pathExists (p + "/git.json") then (
      let gitArgs = filterArgs (builtins.fromJSON (builtins.readFile (p + "/git.json")));
      in if builtins.elem "@" (lib.stringToCharacters gitArgs.url)
      then pkgs.fetchgitPrivate gitArgs
      else pkgs.fetchgit gitArgs)
    else if builtins.pathExists (p + "/github.json") then pkgs.fetchFromGitHub (filterArgs (builtins.fromJSON (builtins.readFile (p + "/github.json"))))
    else {
      name = baseNameOf p;
      outPath = pkgs.filterGit p;
};

in

{
  imports = [
    (import (hackGet ./simple-hydra))
  ];

  networking.firewall.allowedTCPPorts = [
    config.services.hydra.port
  ] ++ lib.optionals config.simple-hydra.useNginx [
    #80
    443
  ];

  services.hydra.package = let
    hydraPkgsSrc = pkgs.fetchFromGitHub {
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "f2cab31ae9970f020fcf48f200dca7c17264776d";
      sha256 = "f185e401299e4dbb531b1ab79c0b3bfeb72c2dc4491c1ba0f0937d970ecad658";
    };
    hydraPkgs = import hydraPkgsSrc {};
    inherit (pkgs) fetchurl;
  in hydraPkgs.hydra.overrideAttrs (old: {
    patches = old.patches or [] ++ lib.attrValues {
      # https://github.com/NixOS/hydra/pull/501#discussion_r171888378
      secureGitHubPatch = pkgs.fetchpatch {
        url = "https://raw.githubusercontent.com/dhall-lang/dhall-lang/9cbfbfedbf7d93894d2d7c9ab0c648b35cd1dcc0/nixops/hydra.patch";
        sha256 = "0yn3bkmwl90hjp609a75fnapxxzj16jivb784vgl1m84xdpi9whm";
      };
      # https://github.com/NixOS/hydra/pull/552
      submodulesPatch = pkgs.fetchpatch {
        url = "https://github.com/NixOS/hydra/compare/df27358e11ad09fe3516a4e41d9fe1fd49f911a7...33880503817774e383fee22c09762aa8020af8ab.diff";
        sha256 = "0m7w6q8jcqcycb5lsqhsa87yc9lwwsx5f9m4g3sk0zvszi874n8c";
      };
      #submodulesPatch = ./fixFetchGit.patch;
      # https://github.com/NixOS/hydra/issues/537
      # https://github.com/NixOS/nix/issues/1888#issuecomment-370242344
      unrestrictEval = ./hydra-unrestrict-eval.patch;
      # https://github.com/mesonbuild/meson/pull/4753
      gitlab = pkgs.fetchpatch {
        url = "https://patch-diff.githubusercontent.com/raw/NixOS/hydra/pull/592.diff";
        sha256 = "0hpmmhshy7cppcrp8bjrj48ba98dkrqfylpyv4nm9s2537bp2aih";
      };
    };
  });

  simple-hydra = {
    enable = true;
  };
}
