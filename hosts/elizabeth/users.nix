{config, secrets, ...}:{
  age.secrets.root-pass.file = "${secrets}/root-pass.age";
  users.users.patrick.hashedPasswordFile = config.age.secrets.root-pass.path;
  users.mutableUsers = false;
}
