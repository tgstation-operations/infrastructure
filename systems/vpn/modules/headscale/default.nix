{
  config,
  inputs,
  pkgs,
  ...
}: {
  services.headscale = {
    enable = true;
    # The release vpn runs. headscale refuses to skip a minor version, so it
    # moves up one at a time, each from its own nixpkgs revision.
    package = inputs.nixpkgs-headscale.legacyPackages.${pkgs.stdenv.hostPlatform.system}.headscale;

    settings = {
      log.level = "warn";
      policy.path = ./headscale-acl.json;
      dns = {
        base_domain = "tg.lan";
      };
      server_url = "https://vpn.tgstation13.org";
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
  security.acme.certs."vpn.tgstation13.org" = {};
  services.caddy.virtualHosts."vpn.tgstation13.org" = {
    useACMEHost = "vpn.tgstation13.org";
    extraConfig = ''
      reverse_proxy ${config.services.headscale.address}:${toString config.services.headscale.port}
    '';
  };
  security.wrappers = {
    headscale = {
      owner = "headscale";
      group = "headscale";
      capabilities = "cap_net_bind_service+eip";
      source = "${config.services.headscale.package}/bin/headscale";
    };
  };
}
