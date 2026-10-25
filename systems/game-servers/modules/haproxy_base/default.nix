{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../../../modules/haproxy_common.nix
  ];
  services.haproxy = {
    config =
      "# ==== GLOBAL CONFIG ====\n"
      + builtins.readFile ./haproxy.conf;
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
          table = "haproxy";
        };
      }
    ];
  };

  # nixpkgs 26.05 dropped network.target from network-addresses-lo's wantedBy and
  # relies on a udev add event instead, which never fires for lo. Without this
  # nothing starts it, 10.248.1.1 never appears and every backend check fails.
  systemd.services.network-addresses-lo = {
    wantedBy = ["network.target"];
    before = ["network.target"];
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
