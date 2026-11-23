{ authorizedKeys }: {
  enable = true;
  ssh = {
    enable = true;
    hostRSAKey = /etc/ssh/ssh_dropbear_host_key;
    inherit authorizedKeys;
  };
}
