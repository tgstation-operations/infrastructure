{...}: {
  imports = [
    ../../../../modules/haproxy_base
  ];

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    8989
  ];

  services.haproxy.config =
    "\n\n# ==== LOCAL CONFIG ====\n"
    + builtins.readFile ./haproxy.conf;
}
