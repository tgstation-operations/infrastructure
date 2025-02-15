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
    80
    443
  ];
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
      "tgs.wiggle.staging.tgstation13.org" = {};
    };
  };
  services.caddy = {
    enable = true;
    package = pkgs-unstable.caddy; # We use caddy on unstable so we get the latest version of it, consistent with the relays
    enableReload = true; # Reload caddy instead of restarting it on config changes
    globalConfig = ''
      auto_https disable_certs  # We use security.acme.certs for this where applicable, so we don't want it to try and get certs
      grace_period 30s # Make sure we're not infinitely waiting for clients on reload
      admin localhost:2019
      metrics
    '';
    virtualHosts = {
      # <https://caddyserver.com/docs/caddyfile/concepts#addresses>
      "tgs.wiggle.staging.tgstation13.org" = {
        useACMEHost = "tgs.wiggle.staging.tgstation13.org";
        extraConfig = ''
          encode gzip zstd
          reverse_proxy localhost:5000
        '';
      };
    };
  };
}
