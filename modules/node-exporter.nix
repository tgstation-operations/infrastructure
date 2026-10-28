{config, ...}: {
  networking.firewall.interfaces.wt0.allowedTCPPorts = [config.services.prometheus.exporters.node.port];

  services.prometheus.exporters = {
    node = {
      enable = true;
      enabledCollectors = ["systemd"];
      extraFlags = [
        "--collector.ethtool"
        "--collector.softirqs"
        "--collector.tcpstat"
      ];
      port = 9100;
    };
  };
}
