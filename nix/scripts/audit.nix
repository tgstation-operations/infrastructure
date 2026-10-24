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

  # The exit status of a skipped test under automake and meson.
  skipped = 77;

  # The derivation determines the test, so a test whose derivation has passed
  # has nothing to check. Where AUDIT_PASSED names a directory, a pass is
  # recorded there as a file named for the derivation.
  vmTest = name:
    stage {
      inherit name;
      tier = "ci";
      text = ''
        nix=(nix --extra-experimental-features "nix-command flakes" --option accept-flake-config false)
        drv=$("''${nix[@]}" path-info --derivation .#checks.x86_64-linux.${name})
        pass=''${AUDIT_PASSED:+$AUDIT_PASSED/$(basename "$drv")}
        if [ -n "$pass" ] && [ -e "$pass" ]; then
          exit ${toString skipped}
        fi
        "''${nix[@]}" build --no-link "$drv^*"
        if [ -n "$pass" ]; then
          mkdir -p "$AUDIT_PASSED"
          touch "$pass"
        fi
      '';
    };

  stages =
    [
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
      (stage {
        name = "actions";
        tier = "hook";
        runtimeInputs = [pkgs.git];
        text = builtins.readFile ./audit/actions.sh;
      })
      (stage {
        name = "shellcheck";
        tier = "hook";
        runtimeInputs = [pkgs.git pkgs.shellcheck];
        text = "git ls-files -z -- '*.sh' '.githooks/*' | xargs -0 shellcheck -S warning";
      })
      (stage {
        name = "statix";
        tier = "hook";
        runtimeInputs = [pkgs.git pkgs.statix];
        text = ''
          status=0
          while IFS= read -r -d "" f; do
            statix check --config statix.toml "$f" || status=1
          done < <(git ls-files -z -- '*.nix')
          exit "$status"
        '';
      })
      (stage {
        name = "deadnix";
        tier = "hook";
        runtimeInputs = [pkgs.git pkgs.deadnix];
        text = "git ls-files -z -- '*.nix' | xargs -0 deadnix --no-lambda-arg --fail";
      })
      (stage {
        name = "hosts";
        tier = "ci";
        runtimeInputs = [pkgs.findutils pkgs.gnugrep pkgs.jq];
        text = builtins.readFile ./audit/hosts.sh;
      })
      (stage {
        name = "rekey";
        tier = "ci";
        runtimeInputs = [pkgs.git pkgs.lix pkgs.python3];
        text = "python3 ${./audit/rekey.py}";
      })
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 (map vmTest [
      "rollback-root"
      "tgstation-server"
      "byond-authentication-bridge"
    ]);

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
        local tier_of=$1 name=$2 bin=$3 log start status=0
        if [ "$tier" = hook ] && [ "$tier_of" != hook ]; then
          return 0
        fi
        log=$(mktemp)
        start=$SECONDS
        "$bin" >"$log" 2>&1 || status=$?
        case $status in
          0) echo "ok    $name ($((SECONDS - start))s)" ;;
          ${toString skipped}) echo "skip  $name ($((SECONDS - start))s)" ;;
          *)
            echo "FAIL  $name ($((SECONDS - start))s)"
            sed 's/^/      /' "$log"
            failed+=("$name")
            ;;
        esac
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
