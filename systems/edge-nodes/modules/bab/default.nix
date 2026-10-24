{
  pkgs,
  config,
  ...
}: let
  package = pkgs.callPackage ../../../../nix/packages/byond-authentication-bridge/package.nix {};
  inherit (package) prisma-engines;
in {
  imports = [
    ../../../../modules/postgres.nix
  ];

  age.secrets.bab_db_connection_string.file = ./../../secrets/bab_db_connection_string.age;

  systemd.services.byond-authentication-bridge = {
    enable = true;
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      DynamicUser = "true";
      ExecStart = "${package}/bin/bab";
      Environment = "NODE_ENV=production PRISMA_QUERY_ENGINE_BINARY=\"${prisma-engines}/bin/query-engine\" PRISMA_QUERY_ENGINE_LIBRARY=\"${prisma-engines}/lib/libquery_engine.node\" PRISMA_INTROSPECTION_ENGINE_BINARY=\"${prisma-engines}/bin/introspection-engine\" PRISMA_FMT_BINARY=\"${prisma-engines}/bin/prisma-fmt\"";
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
