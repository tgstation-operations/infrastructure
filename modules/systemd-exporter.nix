{config, ...}: {
  networking.firewall.interfaces.wt0.allowedTCPPorts = [config.services.prometheus.exporters.systemd.port];

  services.prometheus.exporters.systemd = {
    enable = true;
  };
}
