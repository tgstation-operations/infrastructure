{
  pkgs,
  ...
}: let
  source = pkgs.fetchFromGitHub {
    owner = "alexkar598";
    repo = "bab";
    rev = "d72ea2505a726fb6758223a198604e944b228bd4";
    hash = "sha256-91mGS1xwbt68QtRN8T/TLI2Njw2Keet3I2HybwDmoO0=";
  };
  prisma-version = pkgs.runCommand "prisma-version" {} ''
    cat ${source}/package-lock.json | ${pkgs.jq}/bin/jq -r '.packages."node_modules/prisma".version' > $out
  '';
  prisma = pkgs.prisma.overrideAttrs (finalAttrs: previousAttrs: {

  });
  package = pkgs.buildNpmPackage {
    pname = "byond-authentication-bridge";
    version = "1.0.0";
    src = source;
    npmDepsHash = "sha256-dK8gACPM9GIZS5GvDfsssHm8+Y7IPY9AVI6d9gC7Myo=";
    preBuild = ''
      sed -i 's/"name": "bab",/"name": "bab","bin":{"bab":"dist\/index.js"},/g' package.json
      ${prisma}/bin/prisma generate
    '';
  };
in {
  users = {
    groups.byond-authentication-bridge = { };
    users.byond-authentication-bridge = {
      isSystemUser = true;
      group = "byond-authentication-bridge";
    };
  };

  systemd.services.byond-authentication-bridge = {
    enable = true;
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      User = "byond-authentication-bridge";
      ExecStart = "${package}/bin/bab";
      Environment = "NODE_ENV=produdction";
      WorkingDirectory = "/etc/byond-authentication-bridge";
    };
  };

  environment.etc."byond-authentication-brige/config/production.json" = {
    text = builtins.toJSON {
      server = {
        publicUrl = "http://localhost:12385";
        host = "0.0.0.0";
        proxy = false;
      };
      database = {
        connectionString = "postgresql://postgres:asdfasdf@database:5432/postgres?schema=byond-authentication-bridge";
      };
      logging = {
        http = {
          meta = false;
        };
        file = {
          enabled = true;
        };
        file-err = {
          enabled = true;
        };
      };
    };
    group = "byond-authentication-bridge";
    mode = "0444";
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
    enable = true;
    ensureDatabases = ["byond-authentication-bridge"];
    ensureUsers = [
      {
        name = "byond-authentication-bridge";
        ensureDBOwnership = true;
      }
    ];
  };
}
