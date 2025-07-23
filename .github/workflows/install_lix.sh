#!/usr/bin/env bash

curl --proto '=https' --tlsv1.2 -sSf -L https://install.lix.systems/lix | sh -s -- install linux --no-confirm --enable-flakes --extra-conf "$EXTRA_NIX_CONFIG"
