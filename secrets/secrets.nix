let
  # systems
  lydia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDxTHQOpCFZWlEk7P7KVBFGxMiCUBT+6tDu/cjCCZ+jw lydia";
  elizabeth = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN4Syg9D4bIk0BOqrb/23iQLXObFWNkGkH41vPG7WHsA elizabeth";
  kitty = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFhfv7vvXZZ1L92ZnbXkpgbLXgWZeCZodX9FgwB+fFIa kitty";
  all_systems = [lydia elizabeth kitty];

  # users
  patrick_mary = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMUgf+mHH85a2lwOpFmmFnK6jiy+Hzjl/LaGMxKc6zpG patrick@mary";
  root_lydia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL9j3Z2towbEk1IXl8YeLuDzEodlD4vZKjJa9DE8ldry root@lydia";
  all_users = [patrick_mary root_lydia];

  all = all_users ++ all_systems;
in
{
  allUsers.publicKeys = all;

  "keys/prv/lydia.age".publicKeys = all_users;
  "keys/prv/root_lydia.age".publicKeys = all_users;
  "keys/prv/elizabeth.age".publicKeys = all_users;
  "keys/prv/patrick_elizabeth.age".publicKeys = all_users;
  "keys/prv/kitty.age".publicKeys = all_users;

  "root-pass.age".publicKeys = all;
  "runner-token.age".publicKeys = all;
  "wifi.age".publicKeys = all;

  # ssh user keys
  "root-user-ssh.age".publicKeys = all;

  # vpn
  "nordvpn-config.age".publicKeys = all;
  "nordvpn-pass.age".publicKeys = all;
}
