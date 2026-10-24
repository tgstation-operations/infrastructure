#!/usr/bin/env bash
# Plans a colmena run. Every host is evaluated, and a host is built unless its
# system is already in the binary cache at $1, where only a successful build
# puts it: git history says nothing about what was built or deployed. Writes
# to $GITHUB_OUTPUT, or stdout:
#   build    the build matrix: per tag, or per untagged host, and per system,
#            the hosts to build
#   systems  each host's system and deployment target, for the deploy jobs
set -euo pipefail

cache=$1
flake=${2:-.}

dir=$(mktemp -d)
trap 'rm -rf "$dir"' EXIT

mapfile -t hosts < <(nix eval --json "$flake#colmenaHive.nodes" --apply builtins.attrNames | jq -r '.[]')

evaluate() {
  nix eval --json "$flake#colmenaHive.nodes.$1" --apply 'n: let
    t = n.config.system.build.toplevel;
    d = n.config.deployment;
  in {
    out = t.outPath;
    inherit (t) system;
    inherit (d) tags;
    target = "${d.targetUser}@${d.targetHost}";
  }' >"$dir/$1.json" 2>"$dir/$1.err" || rm "$dir/$1.json"
}

# One host per process, four at a time: a runner has four CPUs, and each takes
# about 1.5 GB.
for host in "${hosts[@]}"; do
  while [ "$(jobs -rp | wc -l)" -ge 4 ]; do
    wait -n
  done
  evaluate "$host" &
done
wait

status=0
for host in "${hosts[@]}"; do
  if [ ! -e "$dir/$host.json" ]; then
    echo "$host does not evaluate:"
    cat "$dir/$host.err"
    status=1
  fi
done >&2
if [ "$status" != 0 ]; then
  exit "$status"
fi

# A cache that cannot be asked is a reason to build, not to skip.
cached() {
  local hash code
  hash=$(basename "$1")
  hash=${hash%%-*}
  code=$(curl -sS -o /dev/null -w '%{http_code}' --max-time 30 "$cache/$hash.narinfo") || true
  case $code in
    200) return 0 ;;
    404) return 1 ;;
  esac
  echo "::warning::$cache answered $code for $1, so it is built"
  return 1
}

for host in "${hosts[@]}"; do
  out=$(jq -r .out "$dir/$host.json")
  if cached "$out"; then
    echo "$host: $out is cached"
    c=true
  else
    echo "$host: $out is not cached"
    c=false
  fi
  jq --arg host "$host" --argjson cached "$c" '. + {$host, $cached}' "$dir/$host.json" >>"$dir/plan"
done >&2

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  exec >>"$GITHUB_OUTPUT"
fi
echo "build=$(jq -sc '
  map(select(.cached | not) | . + {node: (if .tags == [] then .host else "@" + .tags[0] end)})
  | group_by([.node, .system])
  | map({node: .[0].node, system: .[0].system, on: (map(.host) | join(","))})
' "$dir/plan")"
echo "systems=$(jq -sc 'map({key: .host, value: {out, target, tags}}) | from_entries' "$dir/plan")"
