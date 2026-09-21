{ config, secrets, ... }:
{
  # AGENIX
  age.secrets.root-pass.file = "${secrets}/root-pass.age";
  users.users.root.hashedPasswordFile = config.age.secrets.root-pass.path;
  users.mutableUsers = false;

  services.openssh.settings.PermitRootLogin = "prohibit-password";
}
