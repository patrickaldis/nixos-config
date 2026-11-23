{ config, pkgs, ... }:

# So the office build machines can access github private repos via http.
# Not in `cache.nix` because you should probably use your own
# credentials on your own machines, and `cache.nix` is for everyone's
# usage.

{
  nix = {
    envVars = {
      NIX_GITHUB_PRIVATE_USERNAME = "obsidiandeploy";
      NIX_GITHUB_PRIVATE_PASSWORD = "202024ce26187cd7cb9fec6cc07cd24172b3ef5d";
    };
  };
}
