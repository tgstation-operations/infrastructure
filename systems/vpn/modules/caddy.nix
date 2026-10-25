{
  config,
  tg-globals,
  ...
}: {
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  networking.firewall.allowedUDPPorts = [
    80
    443
  ];

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
      server = "https://acme-v02.api.letsencrypt.org/directory";
    };
  };

  services.caddy = {
    enable = true;
    package = tg-globals.caddy.default-package;
    enableReload = true;
  };
}
