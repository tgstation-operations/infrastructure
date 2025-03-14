{
  config,
  pkgs,
  pkgs-unstable,
  inputs,
  headscaleIPv4,
  ...
}: {
  # For Unix sockets, unused for now
  systemd.tmpfiles.rules = [
    "d /run/caddy 644 ${config.services.caddy.user} ${config.services.caddy.group}"
    "d /run/php/caddy 770 ${config.services.caddy.user} ${config.services.caddy.group}"
    "d /run/tgstation-website-v2 770 ${config.services.caddy.user} ${config.services.caddy.group}"
  ];

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    2019 # Caddy admin API and metrics
  ];
  networking.firewall.allowedTCPPorts = [
    # These two are commented out on purpose, a custom firewall is used to only allow access to cloudflare IPs
    #80
    #443
  ];
  networking.firewall.extraInputRules = ''
    # Allow connections from cloudflare
    tcp dport { http, https } ip saddr { # https://www.cloudflare.com/ips-v4/
      173.245.48.0/20,
      103.21.244.0/22,
      103.22.200.0/22,
      103.31.4.0/22,
      141.101.64.0/18,
      108.162.192.0/18,
      190.93.240.0/20,
      188.114.96.0/20,
      197.234.240.0/22,
      198.41.128.0/17,
      162.158.0.0/15,
      104.16.0.0/13,
      104.24.0.0/14,
      172.64.0.0/13,
      131.0.72.0/22,
    } accept
    tcp dport { http, https } ip6 saddr { # https://www.cloudflare.com/ips-v6/
      2400:cb00::/32,
      2606:4700::/32,
      2803:f800::/32,
      2405:b500::/32,
      2405:8100::/32,
      2a06:98c0::/29,
      2c0f:f248::/32,
    } accept
  '';

  age.secrets.cloudflare_api.file = ../secrets/cloudflare_api.age;
  security.acme = {
    acceptTerms = true;
    defaults = {
      dnsProvider = "cloudflare";
      email = "acme@tgstation13.org";
      dnsPropagationCheck = true;
      credentialFiles = {
        "CF_DNS_API_TOKEN_FILE" = config.age.secrets.cloudflare_api.path;
      };
      server = "https://acme-v02.api.letsencrypt.org/directory"; # Production
    };
    certs = {
      "tgstation13.org" = {};
      "forums.tgstation13.org" = {};
      "github-webhooks.tgstation13.org" = {};
    };
  };

  # For manual usage of composer or php
  environment.systemPackages = [
    pkgs.php83Packages.composer
    pkgs.php83
  ];
  users.users.php-caddy = {
    isSystemUser = true;
    extraGroups = ["caddy"];
    group = "php-caddy";
  };
  users.groups.php-caddy = {};
  services.phpfpm = {
    settings = {
      "syslog.facility" = "daemon";
      "syslog.ident" = "phpfpm";
      "error_log" = "syslog";
    };
    phpOptions = ''
      log_errors = On
      error_log = syslog
      variables_order = EGPCS
    '';
    pools = {
      php-caddy = {
        user = "php-caddy";
        group = "caddy";
        phpPackage = pkgs.php83;
        settings = {
          "pm" = "dynamic";
          "pm.max_children" = 75;
          "pm.start_servers" = 10;
          "pm.min_spare_servers" = 5;
          "pm.max_spare_servers" = 20;
          "pm.max_requests" = 500;
          "listen.owner" = config.services.caddy.user;
          "listen.group" = config.services.caddy.group;
        };
      };
    };
  };
  age.secrets.caddy-edge.file = ../secrets/caddy.age;
  systemd.services.caddy = {
    serviceConfig = {
      EnvironmentFile = config.age.secrets.caddy-edge.path;
    };
  };
  services.caddy = {
    enable = true;
    package = pkgs-unstable.caddy.withPlugins {
      plugins = [
        "github.com/WeidiDeng/caddy-cloudflare-ip@v0.0.0-20231130002422-f53b62aa13cb" # Module to retrieve trusted proxy IPs from cloudflare
        "github.com/greenpau/caddy-security" # Security module that provides OAuth
      ];
      hash = "sha256-o/A1YSVSfUvwaepb7IusiwCt2dAGmzZrtM3cb8i8Too=";
    };
    enableReload =
      true; # Reload caddy instead of restarting it on config changes
    globalConfig = ''
      auto_https disable_certs  # We use security.acme.certs for this where applicable, so we don't want it to try and get certs
      grace_period 30s # Make sure we're not infinitely waiting for clients on reload
      admin localhost:2019
      metrics
      servers {
        trusted_proxies cloudflare {
          interval 12h
          timeout 15s
        }
        # <https://caddyserver.com/docs/caddyfile/options#trusted-proxies-strict>
        trusted_proxies_strict
      }
    '';
    virtualHosts = {
      # <https://caddyserver.com/docs/caddyfile/concepts#addresses>
      "tgstation13.org" = {
        useACMEHost = "tgstation13.org";
        extraConfig = ''
          encode gzip zstd
          order authenticate before respond
          order authorize before basicauth
          security {
              oauth identity provider tgstation {
                realm tg
                driver generic
                client_id {env.TG_OAUTH_RAWLOGS_CLIENT_ID}
                client_secret {env.TG_OAUTH_RAWLOGS_CLIENT_SECRET}
                scopes user user.groups
                base_auth_url https://forums.tgstation13.org/app.php/tgapi/oauth/auth
              }

          authentication portal tgstation {
                enable identity provider tgstation
                cookie domain raw-logs.tgstation13.org
                ui {
                  links {
                    "My Identity" "/whoami" icon "las la-user"
                  }
                }

                transform user {
                  match realm tg
                  action add role authp/user
                }

                transform user {
                  match realm tg
                }
              }
              authorization policy raw-logs {
                set auth url https://forums.tgstation13.org/app.php/tgapi/oauth/auth
                allow roles authp/admin authp/user
                validate bearer header
                inject headers with claims
              }
          }
          root ${
            toString inputs.tgstation-website.packages.x86_64-linux.default
          }
          file_server
          php_fastcgi unix/${
            toString config.services.phpfpm.pools.php-caddy.socket
          } {
            env _GET 127.0.0.1
          }
          handle_path /serverinfo.json {
            root /run/tgstation-website-v2/serverinfo.json
            file_server
          }
          handle_path /raw-logs {
            authorize with raw-logs
            root /run/tgstation-website-v2/serverinfo.json
            file_server
          }
          redir /phpBB/ https://forums.tgstation13.org/
          redir /phpBB/*.php* https://forums.tgstation13.org/{http.request.orig_uri.path.file}?{http.request.orig_uri.query}{http.request.orig_uri.path.*/}
        '';
      };
      "forums.tgstation13.org" = {
        useACMEHost = "forums.tgstation13.org";
        extraConfig = ''
          encode gzip zstd
          root /persist/phpbb
          file_server
          php_fastcgi unix/${toString config.services.phpfpm.pools.php-caddy.socket} {
            env DB_HOST {env.DB_HOST}
            env DB_PORT {env.DB_PORT}
            env DB_NAME {env.DB_NAME}
            env DB_USER {env.DB_USER}
            env DB_PASSWORD {env.DB_PASSWORD}
          }
        '';
      };
      "github-webhooks.tgstation13.org" = {
        useACMEHost = "github-webhooks.tgstation13.org";
        extraConfig = ''
          encode gzip zstd
          reverse_proxy localhost:5004 {
            health_uri /health
            health_port 5004
          }
        '';
      };
    };
  };
  # Server Info Fetcher
  systemd.services."tgstation-gameserverdatasync" = {
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Restart = "always";
      RestartSec = "5s";
      RestartMaxDelaySec = "5s";
      User = "caddy";
      Group = "caddy";
      ExecStart = pkgs.writeShellScript "server-info-fetcher.sh" ''
        ${
          pkgs.rustPlatform.buildRustPackage rec {
            pname = "server-info-fetcher";
            version = "0.1.0";
            src = pkgs.fetchFromGitHub {
              owner = "tgstation-operations";
              repo = pname;
              rev = "481c04b83946e6314afeb0a443ef08f069a1ae8c";
              hash = "sha256:0rwas0c9kxpf7dqbyd516xkam5hxdij7fillk7nxhx62z8gzcgcj";
            };
            cargoHash = "sha256-vRVVGVXAvKbQ8lpgDknTKnIL+HYgkPy1R//TbUG4F6o=";
          }
        }/bin/server-info-fetcher --failure-tolerance all --servers blockmoths.tg.lan:3336,tgsatan.tg.lan:1337,tgsatan.tg.lan:1447,tgsatan.tg.lan:5337 /run/tgstation-website-v2/serverinfo.json
      '';
    };
  };
}
