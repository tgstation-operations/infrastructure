{
  config,
  lib,
  pkgs,
  ...
}: {
  systemd.tmpfiles.rules = [
    "d /var/lib/haproxy 770 ${config.services.haproxy.user} ${config.services.haproxy.group}"
  ];
  services.haproxy = {
    enable = true;
    config =
      "# ==== GLOBAL CONFIG ====\n"
      + builtins.readFile ./haproxy.conf;
  };
  systemd.services.haproxy = {
    serviceConfig = {
      AmbientCapabilities = lib.mkForce "CAP_NET_BIND_SERVCE CAP_NET_RAW";
      CapabilityBoundingSet = "CAP_NET_BIND_SERVICE CAP_NET_RAW";
    };
    environment = {
      PROMETHEUS_PORT = "8405";
    };
  };
  services.tailscale.useRoutingFeatures = "server"; # IP Forwarding
}
