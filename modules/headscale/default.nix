{
  config,
  pkgs,
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
  services.headscale = {
    enable = true;
    address = "0.0.0.0";
    port = 443;

    settings = {
      log.level = "warn";
      policy.path = ./headscale-acl.json;
      dns = {
        base_domain = "tg.lan";
      };
      server_url = "https://vpn.tgstation13.org";
      tls_letsencrypt_hostname = "vpn.tgstation13.org";
      metrics_listen_addr = "127.0.0.1:9532";
    };
  };
  security.wrappers = {
    headscale = {
      owner = "headscale";
      group = "headscale";
      capabilities = "cap_net_bind_service+eip";
      source = "${pkgs.headscale}/bin/headscale";
    };
  };
}
