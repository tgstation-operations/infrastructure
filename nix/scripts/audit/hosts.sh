# shellcheck shell=bash
# Every host evaluates, in the colmena hive and in nixosConfigurations, and the
# two give a host the same system. CI builds and deploys the hive; the copy in
# nixosConfigurations is what nixos-rebuild and other tools read. One host per
# process: evaluating them all in one took 40 GB.
nix=(nix --extra-experimental-features "nix-command flakes" --option accept-flake-config false)
err=$(mktemp)
trap 'rm -f "$err"' EXIT

names() {
  "${nix[@]}" eval --json ".#$1" --apply builtins.attrNames | jq -r '.[]'
}

status=0
for host in $({ names colmenaHive.toplevel && names nixosConfigurations; } | sort -u); do
  expr="let f = builtins.getFlake (toString ./.); in {
    hive = f.colmenaHive.toplevel.\"$host\".drvPath or null;
    nixos = f.nixosConfigurations.\"$host\".config.system.build.toplevel.drvPath or null;
  }"
  if ! paths=$("${nix[@]}" eval --impure --json --expr "$expr" 2>"$err"); then
    echo "$host does not evaluate:"
    grep -E '^[[:space:]]*error' -A3 "$err" | grep -v '^--$' | head -8 | sed 's/^/  /'
    status=1
  elif ! jq -e '.hive == null or .nixos == null or .hive == .nixos' <<<"$paths" >/dev/null; then
    echo "$host: the hive builds $(jq -r .hive <<<"$paths"), nixosConfigurations $(jq -r .nixos <<<"$paths")"
    status=1
  fi
done
exit "$status"
