# shellcheck shell=bash
# Every host evaluates without building anything, and its system does not
# depend on the repository's own source, which would change every host on every
# commit. nixosConfigurations is the hive's nodes, so the hive is all there is to
# evaluate. One host per process: evaluating them all in one took 40 GB.
nix=(nix --extra-experimental-features "nix-command flakes" --option accept-flake-config false --option allow-import-from-derivation false)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# With host names given, only those.
hosts=("$@")
if [ ${#hosts[@]} -eq 0 ]; then
  if ! names=$("${nix[@]}" eval --json .#colmenaHive.toplevel --apply builtins.attrNames 2>"$tmp/err"); then
    cat "$tmp/err"
    exit 1
  fi
  mapfile -t hosts < <(jq -r '.[]' <<<"$names")
fi

check() {
  local host=$1 err=$tmp/$1.err out self drv uses
  if ! out=$("${nix[@]}" eval --json ".#colmenaHive.nodes.$host" --apply \
    'n: { self = n._module.specialArgs.self.outPath; drv = n.config.system.build.toplevel.drvPath; }' 2>"$err"); then
    echo "$host does not evaluate:"
    grep -E '^[[:space:]]*error' -A3 "$err" | grep -v '^--$' | head -8 | sed 's/^/  /'
    return 1
  fi
  self=$(jq -r .self <<<"$out")
  drv=$(jq -r .drv <<<"$out")
  mapfile -t uses < <(nix-store -qR "$drv" | grep '\.drv$' | xargs grep -lF "$(basename "$self")" || true)
  if [ ${#uses[@]} -gt 0 ]; then
    echo "$host depends on the repository's own source through:"
    printf '  %s\n' "${uses[@]}"
    return 1
  fi
}

# An evaluation is single-threaded and peaks at about 1.5 GB, so one runs per
# core: four at once on a runner's four cores and 16 GB.
declare -A host_of failed
running=0
reap() {
  local pid
  wait -n -p pid || failed[${host_of[$pid]}]=1
  running=$((running - 1))
}
for host in "${hosts[@]}"; do
  if [ "$running" -ge "$(nproc)" ]; then
    reap
  fi
  check "$host" >"$tmp/$host.out" 2>&1 &
  host_of[$!]=$host
  running=$((running + 1))
done
while [ "$running" -gt 0 ]; do
  reap
done

status=0
for host in "${hosts[@]}"; do
  cat "$tmp/$host.out"
  if [ -n "${failed[$host]:-}" ]; then
    status=1
  fi
done
exit "$status"
