{
  pkgs,
  config,
  ...
}: let
  source = pkgs.fetchFromGitHub {
    owner = "alexkar598";
    repo = "bab";
    rev = "7f8c0572b3b546523a65246e14e9d80f6b20cf03";
    hash = "sha256-8jb08XbHu3padD7kfnmuxGFkSCqxdGHB+yZ8/u7ddU8=";
  };
  prisma-version = pkgs.runCommand "prisma-version" {} ''
    cat ${source}/package-lock.json | ${pkgs.jq}/bin/jq -r '.packages."node_modules/prisma".version' > $out
  '';
  prisma = pkgs.prisma.overrideAttrs (finalAttrs: previousAttrs: {
    version = builtins.readFile prisma-version;
    __intentionallyOverridingVersion = true;
  });
  package = pkgs.buildNpmPackage {
    pname = "byond-authentication-bridge";
    version = "1.0.0";
    src = source;
    nativeBuildInputs = [ source prisma ];
    npmDepsHash = "sha256-dK8gACPM9GIZS5GvDfsssHm8+Y7IPY9AVI6d9gC7Myo=";
    preBuild = ''
      sed -i 's/"name": "bab",/"name": "bab","bin":{"bab":"dist\/index.js"},/g' package.json
      sed -i 's/  provider = "prisma-client-js"/  provider = "prisma-client-js"\n  binaryTargets = ["native", "linux-nixos"]/g' prisma/schema.prisma
      ${prisma}/bin/prisma generate
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
    serviceConfig = {
      DynamicUser = "true";
      ExecStart = "${package}/bin/bab";
      Environment = "NODE_ENV=production";
      EnvironmentFile = config.age.secrets.bab_db_connection_string.path;
      WorkingDirectory = "/etc/byond-authentication-bridge";
    };
  };

  environment.etc = {
    "byond-authentication-bridge/config/production.json" = {
      text = builtins.toJSON {
        server = {
          publicUrl = "https://bab.tgstation13.org";
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
      source = "${source}/config/default.json";
      group = "byond-authentication-bridge";
      mode = "0444";
    };
  };

  security.acme.certs."bab.tgstation13.org" = {};
  services.caddy.virtualHosts."bab.tgstation13.org" = {
    useACMEHost = "bab.tgstation13.org";
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
