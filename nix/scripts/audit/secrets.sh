# Every age file is declared in the secrets.nix beside it, every declared file
# exists, and every age file a module names by path is tracked. agenix -r
# rekeys only what secrets.nix declares, so an undeclared file keeps whatever
# recipients it was last encrypted for.
status=0
fail() {
  echo "$*"
  status=1
}

err=$(mktemp)
trap 'rm -f "$err"' EXIT

declare -A declared
while IFS= read -r -d "" index; do
  dir=$(dirname "$index")
  if ! names=$(nix-instantiate --eval --strict --json -E "builtins.attrNames (import ./$index)" 2>"$err"); then
    fail "$index does not evaluate: $(cat "$err")"
    continue
  fi
  while IFS= read -r name; do
    declared["$dir/$name"]=1
    if [ ! -e "$dir/$name" ]; then
      fail "$index declares $name, which does not exist"
    fi
  done < <(jq -r '.[]' <<<"$names")
done < <(git ls-files -z -- ':(glob)**/secrets.nix')

while IFS= read -r -d "" file; do
  if [ -z "${declared[$file]:-}" ]; then
    fail "$file is not declared in $(dirname "$file")/secrets.nix"
  fi
done < <(git ls-files -z -- ':(glob)**/*.age')

while IFS= read -r -d "" file; do
  dir=$(dirname "$file")
  while IFS= read -r ref; do
    target=$(realpath -m --relative-to=. "$dir/$ref")
    if ! git ls-files --error-unmatch -- "$target" >/dev/null 2>&1; then
      fail "$file names $ref, which is not a tracked file"
    fi
  done < <(grep -v '^[[:space:]]*#' "$file" | grep -oE '\.\.?/[A-Za-z0-9_./-]*\.age' | sort -u)
done < <(git ls-files -z -- ':(glob)**/*.nix')

exit "$status"
