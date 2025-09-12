{
  pkgs,
  rustPlatform,
  lib,
  fetchFromGitHub,
  logs-location,
  serve-address,
  user ? "game-logs",
  group ? "game-logs",
}: let
  logs-server-src = fetchFromGitHub {
    owner = "Mothblocks";
    repo = "tg-public-log-parser";
    rev = "48d179df20768a353c18c558d39ad66bdc98ba5a";
    sha256 = lib.fakeSha256;
  };
  logs-server = rustPlatform.buildRustPackage rec {
    pname = "tg-public-log-parser";
    version = "1.0.0";
    src = logs-server-src;
    cargoLock = "${logs-server-src}/Cargo.lock";
  };
in {
  systemd.services."game-logs-public-${server}" = {
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
        mkdir -p ${logs-server}/data/${server}
        pushd ${logs-server}/data/${server}
        echo "raw_logs_path = \"${logs-location}\"" >config.toml
        echo "address = \"${serve-address}\"" >>config.toml
        popd
        exec ${logs-server}/bin/tg-public-log-parser
      '';
      WorkingDirectory = "${logs-server}/data/${server}";
      Environment = "RUST_LOG=info";
      KillMode = "control-group";
      KillSignal = "KILL";
    };
  };
}
