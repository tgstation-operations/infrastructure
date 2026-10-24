{
  lib,
  pkgs,
  config,
  ...
}: let
  package = pkgs.callPackage ../../../../nix/packages/byond-authentication-bridge/package.nix {};
  # A schema that was pushed rather than migrated has bab's tables but no
  # migration history, and migrate deploy refuses it. It is baselined only if
  # it is what bab's migrations make.
  migrate = pkgs.writeShellApplication {
    name = "byond-authentication-bridge-migrate";
    runtimeInputs = [pkgs.coreutils];
    text = ''
      cd ${package}/lib/node_modules/bab
      export DATABASE_URL="$BAB_DB_CONNECTION_STRING"
      # The CLI otherwise reports every run to checkpoint.prisma.io.
      export CHECKPOINT_DISABLE=1

      prisma() {
        node_modules/.bin/prisma "$@"
      }
      has_history() {
        prisma db execute --schema prisma/schema.prisma --stdin <<<'SELECT FROM _prisma_migrations' >/dev/null 2>&1
      }
      # migrate diff --exit-code is 0 for no difference, 2 for one and 1 for an error.
      differs() {
        local status=0
        prisma migrate diff --from-schema-datasource prisma/schema.prisma "$@" --exit-code || status=$?
        case $status in
          0) return 1 ;;
          2) return 0 ;;
          *) exit "$status" ;;
        esac
      }

      if ! has_history && differs --to-empty >/dev/null; then
        if differs --to-schema-datamodel prisma/schema.prisma --script; then
          echo "The database has no migration history and differs from bab's schema as above, so it is not baselined." >&2
          exit 1
        fi
        for migration in prisma/migrations/*/; do
          prisma migrate resolve --applied "$(basename "$migration")"
        done
      fi
      prisma migrate deploy
    '';
  };
in {
  imports = [
    ../../../../modules/postgres.nix
  ];

  age.secrets.bab_db_connection_string.file = ./../../secrets/bab_db_connection_string.age;

  systemd.services.byond-authentication-bridge = {
    enable = true;
    wantedBy = ["multi-user.target"];
    requires = ["postgresql.target"];
    after = ["postgresql.target"];
    environment = package.prismaEnv // {NODE_ENV = "production";};
    serviceConfig = {
      DynamicUser = "true";
      ExecStartPre = lib.getExe migrate;
      ExecStart = "${package}/bin/bab";
      EnvironmentFile = config.age.secrets.bab_db_connection_string.path;
      WorkingDirectory = "/etc/byond-authentication-bridge";
    };
  };

  environment.etc = {
    "byond-authentication-bridge/config/production.json" = {
      text = builtins.toJSON {
        server = {
          publicUrl = "https://byond-authentication-bridge.tgstation13.org";
          host = "0.0.0.0";
          proxy = true;
          port = "12385";
        };
        logging = {
          http = {
            meta = false;
          };
          file = {
            enabled = false;
          };
          file-err = {
            enabled = false;
          };
        };
      };
      group = "byond-authentication-bridge";
      mode = "0444";
    };
    "byond-authentication-bridge/config/custom-environment-variables.json" = {
      text = builtins.toJSON {
        database = {
          connectionString = "BAB_DB_CONNECTION_STRING";
        };
      };
      group = "byond-authentication-bridge";
      mode = "0444";
    };
    "byond-authentication-bridge/config/default.json" = {
      source = "${package.src}/config/default.json";
      group = "byond-authentication-bridge";
      mode = "0444";
    };
  };

  security.acme.certs."byond-authentication-bridge.tgstation13.org" = {};
  services.caddy.virtualHosts."byond-authentication-bridge.tgstation13.org" = {
    useACMEHost = "byond-authentication-bridge.tgstation13.org";
    extraConfig = ''
      encode gzip zstd
      reverse_proxy localhost:12385
    '';
  };

  services.postgresql = {
    ensureDatabases = ["byond-authentication-bridge"];
    ensureUsers = [
      {
        name = "byond-authentication-bridge";
        ensureDBOwnership = true;
      }
    ];
  };
}
