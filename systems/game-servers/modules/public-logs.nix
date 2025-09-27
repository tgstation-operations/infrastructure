{
  logs-location,
  server-name,
  serve-address,
  pkgs,
  user ? "caddy",
  group ? "tgstation-server",
  ...
}: let
  logs-server-src = pkgs.fetchFromGitHub {
    owner = "Mothblocks";
    repo = "tg-public-log-parser";
    rev = "3debd2d6773df44231438971ea5b94c15e0f6096";
    sha256 = "sha256-GJgiqEYahhH9EMVdKr12tmQqeLGObWytDg8YwaBTQ5A=";
  };
  logs-server = pkgs.rustPlatform.buildRustPackage rec {
    pname = "tg-public-log-parser";
    version = "1.1.0";
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
      ExecStart = pkgs.writeShellScript "start-logs-server.sh" ''
        fail() { echo "$1"; exit 1; }
        ${pkgs.coreutils-full}/bin/id
        ls ${logs-location} >/dev/null 2>&1 || fail "Cannot read log directory ${logs-location}!"
        mkdir -p /tmp/tg-public-log-parser/${server-name}
        cd /tmp/tg-public-log-parser/${server-name}
        echo "raw_logs_path = \"${logs-location}\"" >config.toml
        echo "address = \"${serve-address}\"" >>config.toml
        echo "[ongoing_round_protection]" >>config.toml
        echo "serverinfo = \"https://tgstation13.org/serverinfo.json\"" >>config.toml
        chmod 700 config.toml
        exec ${logs-server}/bin/tg-public-log-parser
      '';
      Environment = "RUST_LOG=info";
      KillMode = "control-group";
      KillSignal = "KILL";
    };
  };
}
