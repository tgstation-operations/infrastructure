{
  pkgs,
  alejandra,
}:
pkgs.writeShellApplication {
  name = "fmt";
  runtimeInputs = [alejandra pkgs.git];
  text = ''
    check=0
    if [ "''${1:-}" = --check ]; then
      check=1
      shift
    fi

    files=("$@")
    if [ ''${#files[@]} -eq 0 ]; then
      cd "$(git rev-parse --show-toplevel)"
      while IFS= read -r -d "" f; do
        if [ -e "$f" ]; then
          files+=("$f")
        fi
      done < <(git ls-files -z --cached --others --exclude-standard -- '*.nix')
    fi

    if [ "$check" = 0 ]; then
      exec alejandra -q "''${files[@]}"
    fi

    # alejandra lists unformatted files on stdout and exits 2. A parse error
    # exits 1, and only -q prints it without the banner.
    rc=0
    alejandra --check "''${files[@]}" 2>/dev/null || rc=$?
    if [ "$rc" = 1 ]; then
      alejandra -q --check "''${files[@]}" || true
    fi
    exit "$rc"
  '';
}
