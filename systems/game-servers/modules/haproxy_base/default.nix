{
  config,
  pkgs,
  lib,
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
  services.tailscale.useRoutingFeatures = lib.mkForce "both"; # IP Forwarding

  networking.iproute2 = {
    enable = true;
    rttablesExtraConfig = "100 haproxy";
  };

  networking.interfaces.lo.ipv4 = {
    addresses = [
      {
        address = "10.248.1.1";
        prefixLength = 24;
      }
    ];
    routes = [
      {
        address = "0.0.0.0";
        prefixLength = 0;
        options = {
          type = "local";
          table = "haproxy";
        };
      }
    ];
  };

  systemd.services.haproxy-iproute2 = {
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    description = "iproute2 rule for haproxy";
    path = [pkgs.bash pkgs.iproute2];
    script = ''
      # Tell traffic from this range to use a custom routing table
      ip rule add from 10.248.1.0/24 lookup 100 prio 50 || echo "Skipped rule setup"
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Restart = "no";
    };
  };
}
