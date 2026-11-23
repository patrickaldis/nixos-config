{ authorizedKeys }: {
  enable = true;
  ssh = {
    enable = true;
    hostKeys = [
      /etc/ssh/ssh_initrd_host_rsa_key
    ];
    inherit authorizedKeys;
  };
}
