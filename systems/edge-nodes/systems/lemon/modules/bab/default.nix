{
  pkgs,
  ...
}: let
  package = pkgs.buildNpmPackage {
    pname = "byond-authentication-bridge";
    version = "1.0.0";
    src = pkgs.fetchFromGitHub {
      owner = "alexkar598";
      repo = "bab";
      rev = "d72ea2505a726fb6758223a198604e944b228bd4";
      hash = "sha256-91mGS1xwbt68QtRN8T/TLI2Njw2Keet3I2HybwDmoO0=";
    };
    npmDepsHash = "sha256-dK8gACPM9GIZS5GvDfsssHm8+Y7IPY9AVI6d9gC7Myo=";
    preBuild = ''
      echo "Start my sed"
      sed -i 's/"name": "bab",/"name": "bab","bin":{"bab":"dist\/index.js"}/g' package.json
      echo "End my sed"
    '';
    postBuild = ''
      npm run generateDbClient
    '';
  };
in {
  systemd.services.byond-authentication-bridge = {
    enable = true;
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      DynamicUser = true;
      ExecStart = "${package}/bin/bab";
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
}
