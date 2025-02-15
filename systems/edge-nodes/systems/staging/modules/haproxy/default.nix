{...}: {
  imports = [
    ../../../../modules/haproxy_base
  ];

  networking.firewall.allowedTCPPorts = [
    # Game Servers
    8989 # funnyname
  ];

  services.haproxy.config =
    "\n\n# ==== LOCAL CONFIG ====\n"
    + builtins.readFile ./haproxy.conf;
}
