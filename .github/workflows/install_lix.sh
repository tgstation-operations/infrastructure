#!/usr/bin/env bash

curl --proto '=https' --tlsv1.2 -sSf -L https://install.lix.systems/lix | sh -s -- install linux --no-confirm --enable-flakes --extra-conf "$EXTRA_NIX_CONFIG"

. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

echo "trusted-users = root @wheel $(whoami)" | sudo tee -a /etc/nix/nix.conf
echo "$EXTRA_NIX_CONFIG" | sudo tee -a /etc/nix/nix.conf

nix config show
