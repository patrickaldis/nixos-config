{config, ...}:{
  users.users.patrick = {
    hashedPasswordFile = config.age.secrets.root-pass.path;
  };
  users.mutableUsers = false;
}
