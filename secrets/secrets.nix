let
  # systems
  tv-box = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN7XKO8WEAkt43cSbOzHtraamI+BuKQh+ZEMMTYbljM4 magic-box";
  obsidian-laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEK8e8MqqUI41g5ymoXJY+NaW7TiEfH/M8qUX3YdB6Pi obsidian-laptop@obsidian-laptop";
  vm = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMTu27K9MREISA+/1CjATVrQTp3cFomIoV0G72nT2/3e root@nixos";
  lydia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDxTHQOpCFZWlEk7P7KVBFGxMiCUBT+6tDu/cjCCZ+jw lydia";

  all = [tv-box obsidian-laptop vm lydia];
in
{
  all.publicKeys = all;

  "keys/prv/lydia.age".publicKeys = all;
  "keys/prv/root_lydia.age".publicKeys = all;

  "root-pass.age".publicKeys = all;
  "runner-token.age".publicKeys = all;
  "wifi.age".publicKeys = all;

  # ssh user keys
  "root-user-ssh.age".publicKeys = all;

  # vpn
  "nordvpn-config.age".publicKeys = all;
  "nordvpn-pass.age".publicKeys = all;
}
