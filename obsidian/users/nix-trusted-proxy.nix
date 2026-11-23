let
  trustedName = "nix_trusted_proxy";
in {
  users.users.${trustedName} = {
    # Priam, the machine running Hydra.
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCnPn68eoAPzyMT0Rq1nEVpf/T+ny1fS6+2yTP4kPbKb3gcecNKUNt4UaGmtiN2gDR3F+qOiDuQWqFmIFvTYTMtu6FtCeL7t76dyK3xhN1Li1xvJnN7QcZvmbXoWw6ALZo6ObVOYD5iVkL6+62xL/xRNm8pVw6TSZ51Hbea+f5lj22kkfJ42bYs2e9QnYjmI7eNQuHsrYGX9O10ppAmQ6+zGGA0zsRdOQx6aszIXnLsNpr5Zwmiy+XQ1aiVKEu+zCslNX/Lyax2Xj7/50f+aGE8QIQc9N4WIVgDaBguGktQO7bgfzn3+1lfKTutCKDPY11d6QIdrbhFD136bP8W0K7V root@naga"
    ];
  };
  nix.settings.trusted-users = [ trustedName ];
}
