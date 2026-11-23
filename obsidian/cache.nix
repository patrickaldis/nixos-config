{ config, options, pkgs, ... }:

{
  nix.settings = {
    substituters = (options.nix.binaryCaches.default or []) ++ [
      "https://nixcache.reflex-frp.org"
      #"s3://obsidian-open-source"
    ];
    trusted-public-keys = [
      "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI=" # reflex-frp
      "obsidian-open-source:KP1UbL7OIibSjFo9/2tiHCYLm/gJMfy8Tim7+7P4o0I="
    ];
  };
}
