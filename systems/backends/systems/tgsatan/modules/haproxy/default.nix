{...}: {
  imports = [
    ../../../../modules/haproxy_base
  ];

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    11337 # Sybil
    11447 # Manuel
    15337 # TGMC
  ];

  services.haproxy.config =
    "\n\n# ==== LOCAL CONFIG ====\n"
    + builtins.readFile ./haproxy.conf;
}
