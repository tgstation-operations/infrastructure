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
    80
    443
  ];
  networking.hosts = {
    "100.64.0.25" = ["idm.staging.tgstation13.org"];
  };
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
      "web.staging.tgstation13.org" = {};
      "idm.staging.tgstation13.org" = {};
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
      hash = "sha256-Z8K1Y6vx+Fnr2nmyw+uPsHR+ByxguiYmdw5OGH6JfBY=";
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
            root /run/tgstation-website-v2/serverinfo.json
            file_server
          }
        '';
      };
      "idm.staging.tgstation13.org" = {
        useACMEHost = "idm.staging.tgstation13.org";
        extraConfig = ''
          encode gzip zstd
          reverse_proxy https://idm.staging.tgstation13.org:8443
        '';
      };
    };
  };
  # Server Info Fetcher
  systemd.services."tgstation-serverdatasync" = {
    serviceConfig = {
      User = "caddy";
      Group = "caddy";
      ExecStart = pkgs.writeShellScript "server-info-fetcher.sh" ''
        ${pkgs.rustPlatform.buildRustPackage rec {
          pname = "server-info-fetcher";
          version = "0.1.0";
          src = pkgs.fetchFromGitHub {
            owner = "tgstation-operations";
            repo = pname;
            rev = "e6964f414101be212d12e4510767b54e45160e53";
            hash = "sha256-I5tVl9Wh4sovO9bVJRPpIQOn4S9dfa5mYad/AB8WPNs=";
          };
          cargoHash = "sha256-vRVVGVXAvKbQ8lpgDknTKnIL+HYgkPy1R//TbUG4F6o=";
        }}/bin/server-info-fetcher --servers 100.64.0.11:3336,100.64.0.1:1337,100.64.0.1:1447,100.64.0.1:5337 /run/tgstation-website-v2/serverinfo.json
      '';
    };
  };
}
