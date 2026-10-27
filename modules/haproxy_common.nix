{
  config,
  lib,
  ...
}: {
  systemd.tmpfiles.rules = [
    "d /var/lib/haproxy 770 ${config.services.haproxy.user} ${config.services.haproxy.group}"
  ];
  services.haproxy = {
    enable = true;
  };
  systemd.services.haproxy = {
    serviceConfig = {
      AmbientCapabilities = lib.mkForce "CAP_NET_BIND_SERVICE CAP_NET_RAW";
      CapabilityBoundingSet = "CAP_NET_BIND_SERVICE CAP_NET_RAW";
    };
    environment = {
      PROMETHEUS_PORT = "8405";
    };
  };

  # The stats and metrics frontends bind every address, so haproxy starts
  # whether or not the overlay is up, and only the overlay may reach them.
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    8888
    (lib.toInt config.systemd.services.haproxy.environment.PROMETHEUS_PORT)
  ];
}
