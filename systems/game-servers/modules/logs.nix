{
  pkgs,
  tg-globals,
  instance-name,
  bind-port,
  internal-port,
  raw-port,
  group ? "tgstation-server",
  ...
}: let
  public-logs-url = "${instance-name}-logs.tgstation13.org";
  raw-logs-url = "raw-${public-logs-url}";
  logs-path = "${tg-globals.tgs.instances-path}/${instance-name}/Configuration/GameStaticFiles/data/logs";
in {
  services = {
    cloudflared.tunnels.primary-tunnel = {
      originRequest.httpHostHeader = "localhost";
      ingress = {
        "${public-logs-url}" = "http://localhost:${internal-port}";
        "${raw-logs-url}" = "http://localhost:${raw-port}";
      };
    };

    caddy = {
      group = "tgstation-server";
      globalConfig = ''
        order authenticate before respond
        order authorize before basicauth

        security {
          oauth identity provider auth {
            realm auth
            driver generic
            client_id Tkj3oWpUiNLIGpU4K6oKZ32UmADhCRSRwsPLo6Bc
            client_secret {env.RAW_LOGS_CLIENT_SECRET}
            scopes openid profile
            base_auth_url https://auth.tgstation13.org
            metadata_url https://auth.tgstation13.org/application/o/raw-logs/.well-known/openid-configuration
          }

          authentication portal myportal {
            enable identity provider auth
            cookie domain ${raw-logs-url}
            transform user {
              match origin auth
              action add role authp/user
            }
          }

          authorization policy mypolicy {
			      set auth url https://${raw-logs-url}/auth/oauth2/auth
            allow roles authp/user
          }
        }
      '';
      virtualHosts = {
        "http://localhost:${internal-port}" = {
          extraConfig = ''
            reverse_proxy localhost:${bind-port}

            header Access-Control-Allow-Origin "*"
          '';
        };

        "http://localhost:${raw-port}" = {
          extraConfig = ''
            handle_path /auth/* {
	            authenticate with myportal
            }

            authorize with mypolicy
            file_server browse
            root ${tg-globals.tgs.instances-path}/${instance-name}/Configuration/GameStaticFiles/data/logs
          '';
        };
      };
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
