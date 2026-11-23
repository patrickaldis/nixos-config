# Puts the Obsidian signing key (ACE9 D7B3 7335 D896 D456  2542 9181 FAA6
# F949 445A) into patrick's keyring.
#
# Public half: committed as ./gpg/<fpr>.asc and imported declaratively by
# home-manager with ultimate trust.
#
# Secret half: travels in the install payload like the SSH keys, as
# secrets/payload/mary/gpg-secret-key.age, and is imported once, on the first
# activation after install, by age.initUser; the payload is deleted right
# after. It is never in the repo or the store in plaintext, and stays
# passphrase-protected inside the keyring. Create the payload file with:
#
#   gpg --export-secret-keys --armor ACE9D7B37335D896D45625429181FAA6F949445A \
#     | nix shell nixpkgs#age -c age -R <recipients> \
#         -o secrets/payload/mary/gpg-secret-key.age
{ pkgs, ... }:
let
  user = "patrick";
  home = "/home/${user}";
  gpg = "${pkgs.gnupg}/bin/gpg";
  gpgconf = "${pkgs.gnupg}/bin/gpgconf";
  asUser = "${pkgs.util-linux}/bin/runuser -u ${user} -- ${pkgs.coreutils}/bin/env HOME=${home}";
in
{
  home-manager.users.${user} = {
    programs.gpg = {
      enable = true;
      # Mutable so the secret key imported below (and anything added by hand)
      # survives home-manager activations.
      mutableKeys = true;
      mutableTrust = true;
      publicKeys = [
        {
          source = ./gpg/ACE9D7B37335D896D45625429181FAA6F949445A.asc;
          trust = "ultimate";
        }
      ];
    };

    programs.git.signing = {
      format = "openpgp";
      key = "ACE9D7B37335D896D45625429181FAA6F949445A";
      signByDefault = true;
    };

    services.gpg-agent = {
      enable = true;
      pinentry.package = pkgs.pinentry-gnome3;
      defaultCacheTtl = 3600;
      maxCacheTtl = 7200;
    };
  };

  age.initUser = pl: /* sh */ ''
    if [ -f ${pl}/gpg-secret-key ]; then
      install -d -m 700 -o ${user} -g users ${home}/.gnupg
      # --batch imports the key still protected by its passphrase, so no
      # pinentry is needed here.
      ${asUser} ${gpg} --batch --import < ${pl}/gpg-secret-key
      # The import auto-starts an agent; don't leave it running (under
      # nixos-install it would keep the chroot busy).
      ${asUser} ${gpgconf} --kill gpg-agent
    fi
  '';
}
