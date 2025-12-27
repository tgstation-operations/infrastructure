{...}: {
  imports = [
    ../haproxy_base
  ];

  networking.firewall.allowedTCPPorts = [
    1337 # Sybil
    3336 # Terry
    1447 # Manuel
    5337 # TGMC
    # 4447 # event-us
    # 4337 # event-eu
    7337 # Effigy
    7777 # event-us (idk ask scriptis)
    8085 # Coolstation
  ];

  services.haproxy.config =
    "\n\n# ==== LOCAL CONFIG ====\n"
    + builtins.readFile ./haproxy.conf;
}
