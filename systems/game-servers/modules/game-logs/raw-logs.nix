{
  logs-location,
  server-name,
  serve-address,
  pkgs,
  lib,
  user ? "caddy",
  group ? "caddy",
  ...
}: let
  logs-server-src = pkgs.fetchFromGitHub {
    owner = "Mothblocks";
    repo = "tg-public-log-parser";
    rev = "48d179df20768a353c18c558d39ad66bdc98ba5a";
    sha256 = "sha256-vyBjCtVFAE75OpXDQ+E8IbC93FHLxmxAiHK6LDqOdA4=";
  };
  logs-server = pkgs.rustPlatform.buildRustPackage rec {
    pname = "tg-public-log-parser";
    version = "1.0.0";
    src = logs-server-src;
    cargoLock.lockFile = "${logs-server-src}/Cargo.lock";
    nativeBuildInputs = with pkgs; [pkg-config openssl];
    PKG_CONFIG_PATH = [
      "${pkgs.openssl.dev}/lib/pkgconfig"
    ];
  };
in {
  systemd.services."game-logs-public-${server-name}" = {
    description = "Game Logs Public Service";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "simple";
      User = user;
      Group = group;
      ExecStart = pkgs.writeShellScript "start-logs-server" ''
        fail() { echo "$1"; exit 1; }
        ls ${logs-location} >/dev/null 2>&1 || fail "Cannot read log directory ${logs-location}!"
        mkdir -p /tmp/tg-public-log-parser/${server-name}
        pushd /tmp/tg-public-log-parser/${server-name}
        echo "raw_logs_path = \"${logs-location}\"" >config.toml
        echo "address = \"${serve-address}\"" >>config.toml
        chmod 700 config.toml
        popd
        exec ${logs-server}/bin/tg-public-log-parser
      '';
      WorkingDirectory = "/tmp/tg-public-log-parser/${server-name}";
      Environment = "RUST_LOG=info";
      KillMode = "control-group";
      KillSignal = "KILL";
    };
  };
}
