{
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
      dns = {
        override_local_dns = false;
        nameservers.global = [
          "1.1.1.1"
          "1.0.0.1"
          "2606:4700:4700::1111"
          "2606:4700:4700::1001"
        ];
      };
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
