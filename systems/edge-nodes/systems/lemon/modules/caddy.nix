{
  config,
  pkgs,
  pkgs-unstable,
  ...
}: let
  phpWithProfiling = pkgs.php83.buildEnv {
    extensions = {
      enabled,
      all,
    }:
      enabled ++ (with all; [memcached]);
  };
  admin_port = 2019;
in {
  imports = [
    ../../../modules/cf-firewall.nix
    (import ../../../modules/authentik.nix {authDomain = "auth.tgstation13.org";})
  ];

  # For Unix sockets, unused for now
  systemd.tmpfiles.rules = [
    "d /run/caddy 644 ${config.services.caddy.user} ${config.services.caddy.group}"
    "d /run/php/caddy 770 ${config.services.caddy.user} ${config.services.caddy.group}"
  ];

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    admin_port # Caddy admin API and metrics
  ];

  age.secrets.cloudflare-api.file = ../../../../../secrets/cloudflare-api.age;
  security.acme = {
    acceptTerms = true;
    defaults = {
      dnsProvider = "cloudflare";
      email = "acme@tgstation13.org";
      dnsPropagationCheck = true;
      credentialFiles = {
        "CF_DNS_API_TOKEN_FILE" = config.age.secrets.cloudflare-api.path;
      };
      server = "https://acme-v02.api.letsencrypt.org/directory"; # Production
    };
    certs = {
      "forums.tgstation13.org" = {};
      "github-webhooks.tgstation13.org" = {};
    };
  };

  # For manual usage of composer or php
  environment.systemPackages = [
    pkgs.php83Packages.composer
    pkgs.imagemagick
    phpWithProfiling
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
        phpPackage = phpWithProfiling;
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
  age.secrets.phpbb_db.file = ../../../secrets/phpbb_db.age;
  systemd.services.caddy = {
    serviceConfig = {
      EnvironmentFile = config.age.secrets.phpbb_db.path;
    };
  };
  services.caddy = {
    enable = true;
    package = pkgs-unstable.caddy.withPlugins {
      plugins = [
        "github.com/WeidiDeng/caddy-cloudflare-ip@v0.0.0-20231130002422-f53b62aa13cb" # Module to retrieve trusted proxy IPs from cloudflare
      ];
      hash = "sha256-w0pJEcwbawr9WKvnyWO++gGHYRUUUxGmGYkXqRvCQ8A=";
    };
    enableReload =
      true; # Reload caddy instead of restarting it on config changes
    globalConfig = ''
      auto_https disable_certs  # We use security.acme.certs for this where applicable, so we don't want it to try and get certs
      grace_period 30s # Make sure we're not infinitely waiting for clients on reload
      admin localhost:${toString admin_port}
      metrics
      servers {
        timeouts {
          read_body 10s
          idle 1m
        }
        trusted_proxies cloudflare {
          interval 12h
          timeout 15s
        }
        # <https://caddyserver.com/docs/caddyfile/options#trusted-proxies-strict>
        trusted_proxies_strict
        client_ip_headers CF-Connecting-IP X-Forwarded-For
      }
    '';
    extraConfig = ''
      (cors) {
        @cors_preflight method OPTIONS
        @cors header Origin {args[0]}

        handle @cors_preflight {
          header Access-Control-Allow-Origin "{args[0]}"
          header Access-Control-Allow-Methods "GET, POST, PUT, PATCH, DELETE"
          header Access-Control-Allow-Headers "Content-Type"
          header Access-Control-Max-Age "3600"
          respond "" 204
        }

        handle @cors {
          header Access-Control-Allow-Origin "{args[0]}"
          header Access-Control-Expose-Headers "Link"
        }
      }
    '';
    virtualHosts = {
      # <https://caddyserver.com/docs/caddyfile/concepts#addresses>
      "forums.tgstation13.org" = {
        useACMEHost = "forums.tgstation13.org";
        extraConfig = ''
          encode gzip zstd
          root /run/tgstation-phpbb/source
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
  services.memcached = {
    enable = true;
    enableUnixSocket = true;
    maxMemory = 512;
    user = "php-caddy";
  };
}
