{allUserKeys, ...}:{
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = allUserKeys;
}
