let
  # systems
  lydia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDxTHQOpCFZWlEk7P7KVBFGxMiCUBT+6tDu/cjCCZ+jw lydia";
  elizabeth = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN4Syg9D4bIk0BOqrb/23iQLXObFWNkGkH41vPG7WHsA elizabeth";
  kitty = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFhfv7vvXZZ1L92ZnbXkpgbLXgWZeCZodX9FgwB+fFIa kitty";
  all_systems = [lydia elizabeth kitty];

  # users
  patrick_mary = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMUgf+mHH85a2lwOpFmmFnK6jiy+Hzjl/LaGMxKc6zpG patrick@mary";
  patrick_lydia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB+AwQptINpEi8HkgGQVs3F2kNSPUuzRauoceszSL6UT patrick@lydia";
  patrick_elizabeth = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOpXsusSVunagWdkDFBRCNC73CZkwoOdf5EcRSeQypxM patrick@elizabeth";
  all_users = [patrick_mary patrick_lydia patrick_elizabeth];

  all = all_users ++ all_systems;
in
{
  allUsers.publicKeys = all_users;

  "payload/lydia/lydia.age".publicKeys = all_users;
  "payload/lydia/patrick_lydia.age".publicKeys = all_users;
  "payload/elizabeth/elizabeth.age".publicKeys = all_users;
  "payload/elizabeth/patrick_elizabeth.age".publicKeys = all_users;
  "payload/kitty/kitty.age".publicKeys = all_users;

  "password/root-pass.age".publicKeys = all;
  "network/wifi.age".publicKeys = all;

  # vpn
  "network/nordvpn-config.age".publicKeys = all;
  "network/nordvpn-pass.age".publicKeys = all;
}
