#!/usr/bin/env bash

curl --proto '=https' --tlsv1.2 -sSf -L https://install.lix.systems/lix | sh -s -- install linux --no-confirm --init none

mkdir -p /etc/nix

echo "$EXTRA_NIX_CONFIG" | sudo tee -a /etc/nix/nix.conf
