#!/usr/bin/env bash
# Finds the hosts selected by $1, a host or an @tag, that do not already run
# and boot the system colmena_plan.sh planned for them in $SYSTEMS, or whose
# systemd is not running cleanly: degraded, still starting, or anything else.
# A host that cannot be asked is deployed to. Writes `on`, the hosts
# comma-separated, to $GITHUB_OUTPUT, or stdout.
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
  state=$(ssh -o StrictHostKeyChecking=accept-new -o BatchMode=yes -T -- "$target" \
    'readlink -e /run/current-system /nix/var/nix/profiles/system; systemctl is-system-running') || true
  if [ "$state" = "$out"$'\n'"$out"$'\nrunning' ]; then
    echo "$host already runs $out"
  else
    echo "$host is deployed to. It answered: ${state//$'\n'/ }"
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
