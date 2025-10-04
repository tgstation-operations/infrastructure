{
  config,
  pkgs,
  pkgs-unstable,
  inputs,
  ...
}: let
  phpWithProfiling = pkgs.php83.buildEnv {
    extensions = {
      enabled,
      all,
    }:
      enabled ++ (with all; [memcached]);
  };
in {
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

  age.secrets.cloudflare-api.file = ../../../secrets/cloudflare-api.age;
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
      "tgstation13.org" = {};
      "forums.tgstation13.org" = {};
      "wiki.tgstation13.org" = {};
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
  age.secrets.phpbb_db.file = ../secrets/phpbb_db.age;
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
      hash = "sha256-hsC894RFb4dASmCDdwZR6RAjrk1/5oflAM1uUX95IYM=";
    };
    enableReload =
      true; # Reload caddy instead of restarting it on config changes
    globalConfig = ''
      auto_https disable_certs  # We use security.acme.certs for this where applicable, so we don't want it to try and get certs
      grace_period 30s # Make sure we're not infinitely waiting for clients on reload
      admin localhost:2019
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
      "tgstation13.org" = {
        useACMEHost = "tgstation13.org";
        extraConfig = ''
          encode gzip zstd
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
            import cors *
            root /run/tgstation-website-v2/serverinfo.json
            file_server
          }
          redir /phpBB/ https://forums.tgstation13.org/
          redir /phpBB/*.php* https://forums.tgstation13.org/{http.request.orig_uri.path.file}?{http.request.orig_uri.query}{http.request.orig_uri.path.*/}
          handle_path /wiki/* {
            redir * https://wiki.tgstation13.org{uri} permanent
          }
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
      "wiki.tgstation13.org" = {
        useACMEHost = "wiki.tgstation13.org";
        extraConfig = ''
          encode gzip zstd
          root /persist/wiki

          @image_files path_regexp ^/images/
          @php_files path_regexp ^/(mw-config/)?(index|load|api|thumb|opensearch_desc|rest|img_auth)\.php
          @static_files path_regexp ^/(resources/(assets|lib|src)|COPYING|CREDITS|(skins|extensions)/.+\.(css|js|gif|jpg|jpeg|png|svg|wasm|ttf|woff|woff2)$)
          @not_a_file {
            # no this cannot be deduped, sorry :(
            not path_regexp ^/images/
            not path_regexp ^/(mw-config/)?(index|load|api|thumb|opensearch_desc|rest|img_auth)\.php
            not path_regexp ^/(resources/(assets|lib|src)|COPYING|CREDITS|(skins|extensions)/.+\.(css|js|gif|jpg|jpeg|png|svg|wasm|ttf|woff|woff2)$)
          }

          ## Handle everything that would not be a file as a page name
          # apparently just redirecting to index.php is ok, because
          # mw infers the original path from the header. WTF?
          rewrite @not_a_file /index.php

          ## Don't send deleted images
          handle /images/deleted/* {
            respond 404
          }

          # Send static image files, do this before trying to run any php code
          handle @image_files {
            header X-Content-Type-Options nosniff
            file_server
          }

          # Run any .php file
          handle @php_files {
            php_fastcgi unix/${toString config.services.phpfpm.pools.php-caddy.socket} {
              env WIKI_DB_URI {env.WIKI_DB_URI}
              env WIKI_DB_NAME {env.WIKI_DB_NAME}
              env WIKI_DB_USER {env.WIKI_DB_USER}
              env WIKI_DB_PASSWORD {env.WIKI_DB_PASSWORD}
              env WIKI_SECRET_KEY {env.WIKI_SECRET_KEY}
              env WIKI_OAUTH2_CLIENT_ID {env.WIKI_OAUTH2_CLIENT_ID}
              env WIKI_OAUTH2_CLIENT_SECRET {env.WIKI_OAUTH2_CLIENT_SECRET}
            }
          }

          # Serve static files
          handle @static_files {
            header Cache-Control "public"
            file_server
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
            cargoHash = "sha256-x1Ui63dVxEKULKBsynmMv0cIK/ZzkfhRTOQArmUOuP4=";
          }
        }/bin/server-info-fetcher --failure-tolerance all --servers blockmoths.tg.lan:3336,tgsatan.tg.lan:1337,tgsatan.tg.lan:1447,tgsatan.tg.lan:5337,tgsatan.tg.lan:7777 /run/tgstation-website-v2/serverinfo.json
      '';
    };
  };
}
