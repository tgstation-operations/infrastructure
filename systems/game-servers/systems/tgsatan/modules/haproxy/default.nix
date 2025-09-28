{...}: {
  imports = [
    ../../../../modules/haproxy_base
  ];

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    11337 # Sybil
    11447 # Manuel
    15337 # TGMC
    17337 # Effigy
    17777 # Event Hall US
  ];

  services.haproxy.config =
    "\n\n# ==== LOCAL CONFIG ====\n"
    + builtins.readFile ./haproxy.conf;
}
