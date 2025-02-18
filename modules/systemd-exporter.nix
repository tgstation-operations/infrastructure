{
  config,
  pkgs,
  ...
}: {
  services.prometheus.exporters.systemd = {
    enable = true;
  };
}
