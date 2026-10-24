# shellcheck shell=bash
# Every host evaluates without building anything, and its system does not
# depend on the repository's own source, which would change every host on every
# commit. nixosConfigurations is the hive's nodes, so the hive is all there is to
# evaluate. One host per process: evaluating them all in one took 40 GB.
nix=(nix --extra-experimental-features "nix-command flakes" --option accept-flake-config false --option allow-import-from-derivation false)
err=$(mktemp)
trap 'rm -f "$err"' EXIT

# With host names given, only those.
hosts=("$@")
if [ ${#hosts[@]} -eq 0 ]; then
  if ! names=$("${nix[@]}" eval --json .#colmenaHive.toplevel --apply builtins.attrNames 2>"$err"); then
    cat "$err"
    exit 1
  fi
  mapfile -t hosts < <(jq -r '.[]' <<<"$names")
fi

status=0
for host in "${hosts[@]}"; do
  if ! out=$("${nix[@]}" eval --json ".#colmenaHive.nodes.$host" --apply \
    'n: { self = n._module.specialArgs.self.outPath; drv = n.config.system.build.toplevel.drvPath; }' 2>"$err"); then
    echo "$host does not evaluate:"
    grep -E '^[[:space:]]*error' -A3 "$err" | grep -v '^--$' | head -8 | sed 's/^/  /'
    status=1
    continue
  fi
  self=$(jq -r .self <<<"$out")
  drv=$(jq -r .drv <<<"$out")
  mapfile -t uses < <(nix-store -qR "$drv" | grep '\.drv$' | xargs grep -lF "$(basename "$self")" || true)
  if [ ${#uses[@]} -gt 0 ]; then
    echo "$host depends on the repository's own source through:"
    printf '  %s\n' "${uses[@]}"
    status=1
  fi
done
exit "$status"
