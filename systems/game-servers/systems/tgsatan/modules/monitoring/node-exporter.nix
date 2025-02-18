{
  config,
  pkgs,
  ...
}: {
  services.prometheus.exporters = {
    node = {
      enable = true;
      enabledCollectors = ["systemd"];
      extraFlags = [
        "--collector.ethtool"
        "--collector.softirqs"
        "--collector.tcpstat"
      ];
    };
  };
}
