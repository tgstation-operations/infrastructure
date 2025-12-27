{...}: {
  imports = [
    ../../../../modules/haproxy_base
  ];

  networking.firewall.allowedTCPPorts = [
    # Game Servers
    8989 # funnyname
    8085
  ];

  services.haproxy.config =
    "\n\n# ==== LOCAL CONFIG ====\n"
    + builtins.readFile ./haproxy.conf;
}
