#!/usr/bin/env bash

set -euo pipefail

AKEYLESS_DOWNLOAD_URL="https://akeyless-cli.s3.us-east-2.amazonaws.com/cli/latest/cli-linux-amd64"
TALOS_ENDPOINT="192.168.1.110"
TALOS_NODE="192.168.1.81"

# --- Tailscale ---
echo "Setup Tailscale..."
sudo tailscale up --accept-routes --auth-key="$TS_AUTH_KEY"
echo "Tailscale connected!!"

# --- Akeyless CLI ---
echo "Installing Akeyless CLI..."
curl -o /tmp/akeyless "$AKEYLESS_DOWNLOAD_URL"
chmod +x /tmp/akeyless
sudo mv /tmp/akeyless /usr/local/bin/akeyless
mkdir -p ~/.akeyless
akeyless --version > /dev/null 2>&1 # Skip first interaction
echo "Akeyless CLI installed!"

# --- Akeyless Auth ---
echo "Authenticating to Akeyless..."
akeyless configure \
  --access-id "$AKEYLESS_ACCESS_ID" \
  --access-key "$AKEYLESS_ACCESS_KEY" \
  --profile "default"
echo "Akeyless authenticated!"

# --- SOPS Age Key ---
echo "Fetching SOPS age key..."
mkdir -p ~/.config/sops/age
akeyless get-secret-value --name /personal/sops > ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
echo "SOPS age key configured!"
