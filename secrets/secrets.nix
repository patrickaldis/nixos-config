let
  # systems
  lydia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDxTHQOpCFZWlEk7P7KVBFGxMiCUBT+6tDu/cjCCZ+jw lydia";
  elizabeth = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN4Syg9D4bIk0BOqrb/23iQLXObFWNkGkH41vPG7WHsA elizabeth";
  all_systems = [lydia elizabeth];

  # users
  patrick_mary = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMUgf+mHH85a2lwOpFmmFnK6jiy+Hzjl/LaGMxKc6zpG patrick@mary";
  all_users = [patrick_mary];

  all = all_users ++ all_systems;
in
{
  allUsers.publicKeys = all;

  "keys/prv/lydia.age".publicKeys = all_users;
  "keys/prv/root_lydia.age".publicKeys = all_users;
  "keys/prv/elizabeth.age".publicKeys = all_users;
  "keys/prv/patrick_elizabeth.age".publicKeys = all_users;

  "root-pass.age".publicKeys = all;
  "runner-token.age".publicKeys = all;
  "wifi.age".publicKeys = all;

  # ssh user keys
  "root-user-ssh.age".publicKeys = all;

  # vpn
  "nordvpn-config.age".publicKeys = all;
  "nordvpn-pass.age".publicKeys = all;
}
