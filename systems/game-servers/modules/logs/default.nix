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

  # RS256 JWT public key from https://auth.tgstation13.org/application/o/raw-logs/jwks. See https://docs.authcrunch.com/docs/authorize/token-verification, plugin is too stupid to use the OIDC JWKS URL
  public-key-path = ./public_key.pem;
in {
  # LIFE IS PAIN
  networking.hosts = {
    "100.64.3.35" = ["auth.tgstation13.org"];
  };

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

      virtualHosts = {
        "http://localhost:${internal-port}" = {
          extraConfig = ''
            reverse_proxy localhost:${bind-port}

            header Access-Control-Allow-Origin "*"
          '';
        };

        "http://localhost:${raw-port}" = {
          extraConfig = ''
            # directive execution order is only as stated if enclosed with route.
            route {
                # https://old.reddit.com/r/selfhosted/comments/10wch2i/authentik_w_caddy/j7ml255/
                # always forward outpost path to actual outpost
                reverse_proxy /outpost.goauthentik.io/* https://auth.tgstation13.org {
                    header_up Host ${raw-logs-url}
                }

                # forward authentication to outpost
                forward_auth https://auth.tgstation13.org {
                    uri /outpost.goauthentik.io/auth/caddy

                    # capitalization of the headers is important, otherwise they will be empty
                    copy_headers X-Authentik-Username X-Authentik-Groups X-Authentik-Email X-Authentik-Name X-Authentik-Uid X-Authentik-Jwt X-Authentik-Meta-Jwks X-Authentik-Meta-Outpost X-Authentik-Meta-Provider X-Authentik-Meta-App X-Authentik-Meta-Version

                    # optional, in this config trust all private ranges, should probably be set to the outposts IP
                    # Dominion: Just using the TS internal IP here
                    trusted_proxies 100.64.0.0/16
                }

                file_server browse
                root ${tg-globals.tgs.instances-path}/${instance-name}/Configuration/GameStaticFiles/data/logs
            }
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
