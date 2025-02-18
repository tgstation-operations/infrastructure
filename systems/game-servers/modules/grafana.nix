{
  config,
  pkgs,
  ...
}: {
  networking.firewall.allowedTCPPorts = [
    3000
  ];
  networking.firewall.allowedUDPPorts = [
    3000
  ];
  services.grafana = {
    enable = true;

    settings = {
      analytics.reporting_enabled = false;

      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        enforce_domain = false;
        enable_gzip = true;
      };
    };
  };
}
