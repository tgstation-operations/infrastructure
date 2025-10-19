{
  pkgs,
  tg-globals,
  instance-name,
  bind-port,
  internal-port,
  group ? "tgstation-server",
  ...
}: let
  public-logs-url = "${instance-name}-logs.tgstation13.org";
  logs-path = "${tg-globals.tgs.instances-path}/${instance-name}/Configuration/GameStaticFiles/data/logs";
in {
  services = {
    cloudflared.tunnels.primary-tunnel.ingress = {
      "${public-logs-url}" = "http://localhost:${bind-port}";
    };

    caddy.virtualHosts."http://localhost:${internal-port}" = {
      extraConfig = ''
        reverse_proxy localhost:${bind-port}
      '';
    };

    tg-public-log-parser."${instance-name}" = {
      enable = true;
      supplementary-groups = group;
      config = {
        raw_logs_path = logs-path;
        address = "0.0.0.0:${bind-port}";
        ongoing_round_protection = {
          serverinfo = "https://tgstation13.org/serverinfo.json";
        };
      };
    };
  };

  system.activationScripts.tgs-data-chmod = pkgs.lib.stringAfter ["users"] ''
    chmod g+rx ${tg-globals.tgs.root-path}
    chmod g+rx ${tg-globals.tgs.instances-path}
    chmod g+rx ${tg-globals.tgs.instances-path}/${instance-name}
    chmod g+rx ${tg-globals.tgs.instances-path}/${instance-name}/Configuration
    chmod g+rx ${tg-globals.tgs.instances-path}/${instance-name}/Configuration/GameStaticFiles
    chmod g+rx ${tg-globals.tgs.instances-path}/${instance-name}/Configuration/GameStaticFiles/data
    chmod -R g+rx ${tg-globals.tgs.instances-path}/${instance-name}/Configuration/GameStaticFiles/data/logs
  '';
}
