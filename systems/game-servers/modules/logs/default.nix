{
  config,
  pkgs,
  tg-globals,
  instance-name,
  bind-port,
  internal-port,
  raw-port,
  raw-internal-port,
  enable-public-logs ? true,
  oidc-settings ? {
    OpenIDConnectSettings = {
      Authority = "https://auth.tgstation13.org/application/o/raw-logs";
      ClientId = "kD6xu5pXLjXmOGqpsavXuq3dkDQ9m14oRdLv1NmX";
    };
    age-name = "raw-logs-oidc-reverse-proxy";
    age-path = ../../secrets/raw-logs-oidc-reverse-proxy.age;
  },
  ...
}: let
  public-logs-url = "${instance-name}-logs.tgstation13.org";
  raw-logs-url = "raw-${public-logs-url}";
  logs-path = "${tg-globals.tgs.instances-path}/${instance-name}/Configuration/GameStaticFiles/data/logs";
  group = config.services.tgstation-server.groupname;
in {
  users.users.caddy.extraGroups = [ group ];

  services = {
    cloudflared.tunnels.primary-tunnel = {
      originRequest.httpHostHeader = "localhost";
      ingress = {
        "${public-logs-url}" = pkgs.lib.mkIf enable-public-logs "http://localhost:${internal-port}";
        "${raw-logs-url}" = "http://localhost:${raw-port}";
      };
    };

    caddy = {
      virtualHosts = {
        "http://localhost:${internal-port}" = {
          extraConfig = ''
            reverse_proxy localhost:${bind-port}

            header Access-Control-Allow-Origin "*"
          '';
        };

        "http://localhost:${raw-internal-port}" = {
          extraConfig = ''
              root ${tg-globals.tgs.instances-path}/${instance-name}/Configuration/GameStaticFiles/data/logs
              file_server browse
          '';
        };
      };
    };

    tg-public-log-parser."${instance-name}" = pkgs.lib.mkIf enable-public-logs {
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

    oidc-reverse-proxy."${instance-name}" = {
      enable = true;
      config = {
        Urls = "http://localhost:${raw-port}";
        TargetUrl = "http://localhost:${raw-internal-port}";
        OpenIDConnectSettings = oidc-settings.OpenIDConnectSettings;
      };
      environmentFile = config.age.secrets."${oidc-settings.age-name}".path;
    };
  };

  age.secrets."${oidc-settings.age-name}".file = oidc-settings.age-path;

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
