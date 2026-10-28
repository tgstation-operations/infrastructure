#!/usr/bin/env bash
# Joins the runner to NetBird with the setup key in $NETBIRD_SETUP_KEY. The
# client is the release the hosts run, checked against the checksum its
# release publishes.
set -euo pipefail

version=0.81.2
case $(uname -m) in
x86_64) arch=amd64 sha256=a3a5f97d67c8854b33aa562c0bf2244430f07c724cde5ab522f211b49c75c354 ;;
aarch64) arch=arm64 sha256=8152afcc5b5609463d304f8c5ce835fa0d645cc745b0b689c19b1cc4acd1197c ;;
*)
  echo "netbird_join.sh: no NetBird release is pinned for $(uname -m)" >&2
  exit 1
  ;;
esac

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -fsSL -o "$tmp/netbird.tar.gz" \
  "https://github.com/netbirdio/netbird/releases/download/v$version/netbird_${version}_linux_$arch.tar.gz"
echo "$sha256  $tmp/netbird.tar.gz" | sha256sum -c -
tar -xzf "$tmp/netbird.tar.gz" -C "$tmp" netbird
sudo install -m 755 "$tmp/netbird" /usr/local/bin/netbird

sudo netbird service install
sudo netbird service start
printf '%s' "$NETBIRD_SETUP_KEY" >"$tmp/setup-key"
sudo netbird up --management-url https://netbird.tgstation13.org:443 \
  --setup-key-file "$tmp/setup-key" --hostname "ci-$GITHUB_RUN_ID-$GITHUB_JOB"

# up returns once logged in; the peers, and their names, come with the first
# network map.
timeout 60 bash -c 'until netbird status | grep -Eq "^Peers count: [0-9]+/[1-9]"; do sleep 1; done'
netbird status
