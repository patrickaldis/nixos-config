{ config, secrets, ... }:
{
  # AGENIX
  age.secrets = {
    root-pass.file = "${secrets}/root-pass.age";
    root-user-ssh = {
      file = "${secrets}/root-user-ssh.age";
      path = "/root/.ssh/id_ed25519";
      owner = "root";
      mode = "0600";
    };
  };

  # USERS
  users.users.root = {
    hashedPasswordFile = config.age.secrets.root-pass.path;
  };
  users.mutableUsers = false;

  # SSH
  system.activationScripts.rootSshPubKey = ''
    install -d -m 700 -o root -g root /root/.ssh
    install -m 644 -o root -g root ${secrets}/root-user-ssh.pub /root/.ssh/id_ed25519.pub
  '';
  services.openssh.settings.PermitRootLogin = "yes";
}
