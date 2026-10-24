{
  pkgs,
  fmt,
}: let
  inherit (pkgs) lib;

  # A hook stage runs on every commit; a ci stage only in a full run.
  stage = {
    name,
    tier,
    runtimeInputs ? [],
    text,
  }: {
    inherit name tier;
    bin = lib.getExe (pkgs.writeShellApplication {
      name = "audit-${name}";
      inherit runtimeInputs text;
    });
  };

  stages = [
    (stage {
      name = "fmt";
      tier = "hook";
      runtimeInputs = [fmt];
      text = "fmt --check";
    })
    (stage {
      name = "secrets";
      tier = "hook";
      runtimeInputs = [pkgs.git pkgs.jq pkgs.lix];
      text = builtins.readFile ./audit/secrets.sh;
    })
  ];

  count = tier:
    toString (builtins.length (
      if tier == "hook"
      then builtins.filter (s: s.tier == "hook") stages
      else stages
    ));
in
  pkgs.writeShellApplication {
    name = "audit";
    runtimeInputs = [pkgs.git pkgs.coreutils];
    text = ''
      tier=ci
      count=${count "ci"}
      case "''${1:-}" in
        --hook)
          tier=hook
          count=${count "hook"}
          ;;
        "") ;;
        *)
          echo "usage: audit [--hook]" >&2
          exit 2
          ;;
      esac
      echo "audit: $(readlink -f "$0"), $tier tier, $count stages"
      cd "$(git rev-parse --show-toplevel)"

      failed=()
      run() {
        local tier_of=$1 name=$2 bin=$3 log start
        if [ "$tier" = hook ] && [ "$tier_of" != hook ]; then
          return 0
        fi
        log=$(mktemp)
        start=$SECONDS
        if "$bin" >"$log" 2>&1; then
          echo "ok    $name ($((SECONDS - start))s)"
        else
          echo "FAIL  $name ($((SECONDS - start))s)"
          sed 's/^/      /' "$log"
          failed+=("$name")
        fi
        rm -f "$log"
      }

      ${lib.concatMapStringsSep "\n" (s: "run ${s.tier} ${s.name} ${s.bin}") stages}

      if [ ''${#failed[@]} -gt 0 ]; then
        echo "audit: ''${#failed[@]} of $count failed: ''${failed[*]}"
        exit 1
      fi
      echo "audit: all $count passed"
    '';
  }
