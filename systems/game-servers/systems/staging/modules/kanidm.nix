{
  config,
  pkgs,
  lib,
  headscaleIPv4,
  ...
}: {
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    8443
  ];
  users.users.kanidm.extraGroups = [
    "caddy"
  ];

  services.kanidm = {
    enableServer = true;
    serverSettings = {
      bindaddress = lib.mkDefault "${headscaleIPv4}:8443"; # Default
      role = lib.mkDefault "WriteReplica"; # Default
      domain = lib.mkDefault "idm.tgstation13.org"; # If changed, you MUST run `kanidmd domain rename` immediately after. changes will break shit
      origin = lib.mkDefault "https://idm.tgstation13.org";
      tls_chain = "/var/lib/acme/${config.services.kanidm.serverSettings.domain}/fullchain.pem";
      tls_key = "/var/lib/acme/${config.services.kanidm.serverSettings.domain}/key.pem";
    };
  };
}
