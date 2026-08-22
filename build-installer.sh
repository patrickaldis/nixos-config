#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Build the ISO
echo "Building ISO..."
nix build .#nixosConfigurations.installer.config.system.build.isoImage

# Decrypt keys to temp files
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

echo "Decrypting keys..."
age -d -i ~/.ssh/id_ed25519 secrets/keys/prv/lydia.age > "$TMPDIR/lydia"
age -d -i ~/.ssh/id_ed25519 secrets/keys/prv/root_lydia.age > "$TMPDIR/root_lydia"
cp secrets/keys/pub/lydia.pub "$TMPDIR/lydia.pub"
cp secrets/keys/pub/root_lydia.pub "$TMPDIR/root_lydia.pub"

# Copy ISO and make writable
ISO_SRC=$(echo result/iso/*.iso)
ISO_OUT="$SCRIPT_DIR/installer.iso"

echo "Adding keys to ISO..."
cp "$ISO_SRC" "$ISO_OUT"
chmod +w "$ISO_OUT"

# Add keys to ISO
xorriso -indev "$ISO_OUT" -outdev "$ISO_OUT" \
  -map "$TMPDIR/lydia" /lydia \
  -map "$TMPDIR/lydia.pub" /lydia.pub \
  -map "$TMPDIR/root_lydia" /root_lydia \
  -map "$TMPDIR/root_lydia.pub" /root_lydia.pub \
  -boot_image any replay \
  2>/dev/null

echo "Done: $ISO_OUT"
