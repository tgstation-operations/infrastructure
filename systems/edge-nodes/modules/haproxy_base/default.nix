{...}: {
  imports = [
    ../../../../modules/haproxy_common.nix
  ];
  services.haproxy = {
    config =
      "# ==== GLOBAL CONFIG ====\n"
      + builtins.readFile ./haproxy.conf;
  };
  services.tailscale.useRoutingFeatures = "server"; # IP Forwarding
}
