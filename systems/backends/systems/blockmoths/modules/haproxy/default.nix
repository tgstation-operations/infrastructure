{...}: {
  imports = [
    ../../../../modules/haproxy_base
  ];

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    13336 # Terry
  ];

  services.haproxy.config =
    "\n\n# ==== LOCAL CONFIG ====\n"
    + builtins.readFile ./haproxy.conf;
}
