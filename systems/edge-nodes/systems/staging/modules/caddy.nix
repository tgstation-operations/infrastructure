{
  config,
  pkgs,
  pkgs-unstable,
  inputs,
  ...
}: {
  # For Unix sockets, unused for now
  systemd.tmpfiles.rules = [
    "d /run/caddy 644 ${config.services.caddy.user} ${config.services.caddy.group}"
    "d /run/php/caddy 770 ${config.services.caddy.user} ${config.services.caddy.group}"
  ];

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    2019 # Caddy admin API and metrics
  ];
  networking.firewall.allowedTCPPorts = [
    80
    443
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
      "web.staging.tgstation13.org" = {};
    };
  };
  users.users.php-caddy = {
    isSystemUser = true;
    extraGroups = [
      "caddy"
    ];
    group = "php-caddy";
  };
  users.groups.php-caddy = {};
  services.phpfpm.pools = {
    php-caddy = {
      user = "php-caddy";
      group = "caddy";
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
  services.caddy = {
    enable = true;
    package = pkgs-unstable.caddy.withPlugins {
      plugins = [
        "github.com/WeidiDeng/caddy-cloudflare-ip@v0.0.0-20231130002422-f53b62aa13cb" # Module to retrieve trusted proxy IPs from cloudflare
      ];
      hash = "sha256-AaA+Mm2te30ki7YnUcfkb1lwTA+AT3FoogSgyek7AKM=";
    };
    enableReload = true; # Reload caddy instead of restarting it on config changes
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
        client_ip_headers CF-Connecting-IP X-Forwarded-For
        #trusted_proxies_strict # <https://caddyserver.com/docs/caddyfile/options#trusted-proxies-strict>
      }
    '';
    virtualHosts = {
      # <https://caddyserver.com/docs/caddyfile/concepts#addresses>
      "web.staging.tgstation13.org" = {
        useACMEHost = "web.staging.tgstation13.org";
        extraConfig = ''
          encode gzip zstd
          root ${toString inputs.tgstation-website.packages.x86_64-linux.default}
          file_server
          php_fastcgi unix/${toString config.services.phpfpm.pools.php-caddy.socket} {
            env _GET 127.0.0.1
          }
          handle_path /serverinfo.json {
            root /run/tgstation-server-info-fetcher/serverinfo.json
            file_server
          }
        '';
      };
    };
  };
}
