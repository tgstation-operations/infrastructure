# shellcheck shell=bash
# Every action a workflow uses is pinned by full commit SHA. A tag can be moved
# to other code, which would then run with the deploy secrets.
status=0
while IFS= read -r -d "" file; do
  while IFS= read -r hit; do
    line=${hit%%:*}
    ref=${hit#*:}
    ref=${ref%%#*}
    ref=${ref#*uses:}
    ref=$(tr -d "\"' " <<<"$ref")
    case "$ref" in
      ./* | docker://*@sha256:*) continue ;;
    esac
    if ! [[ $ref =~ ^[^@]+@[0-9a-f]{40}$ ]]; then
      echo "$file:$line: $ref is not pinned by commit SHA"
      status=1
    fi
  done < <(grep -nE '^[[:space:]]*(-[[:space:]]*)?uses:' "$file")
done < <(git ls-files -z -- ':(glob).github/workflows/*.y*ml' ':(glob).github/actions/**/action.y*ml')
exit "$status"
