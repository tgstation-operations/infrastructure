#!/usr/bin/env bash
# Finds the hosts selected by $1, a host or an @tag, that do not already run
# and boot the system colmena_plan.sh planned for them in $SYSTEMS. A host that
# cannot be asked is deployed to. Writes `on`, the hosts comma-separated, to
# $GITHUB_OUTPUT, or stdout.
set -euo pipefail

node=$1

mapfile -t hosts < <(jq -r --arg node "$node" '
  to_entries[] | select(.key == $node or any(.value.tags[]; "@" + . == $node)) | .key
' <<<"$SYSTEMS")
if [ ${#hosts[@]} -eq 0 ]; then
  echo "no host is $node" >&2
  exit 1
fi

on=()
for host in "${hosts[@]}"; do
  target=$(jq -r --arg host "$host" '.[$host].target' <<<"$SYSTEMS")
  out=$(jq -r --arg host "$host" '.[$host].out' <<<"$SYSTEMS")
  # The options colmena connects with. The profile is what the host boots, and
  # a switch sets it before it activates.
  if running=$(ssh -o StrictHostKeyChecking=accept-new -o BatchMode=yes -T -- "$target" \
    readlink -e /run/current-system /nix/var/nix/profiles/system) &&
    [ "$running" = "$out"$'\n'"$out" ]; then
    echo "$host already runs $out"
  else
    echo "$host does not run $out"
    on+=("$host")
  fi
done >&2

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  exec >>"$GITHUB_OUTPUT"
fi
(
  IFS=,
  echo "on=${on[*]}"
)
