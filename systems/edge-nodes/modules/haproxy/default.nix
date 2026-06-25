{config, ...}: {
  imports = [
    ../haproxy_base
  ];

  networking.firewall.allowedTCPPorts = [
    1337 # Sybil
    80
    3336 # Terry
    1447 # Manuel
    1887 # Manuel-2
    5337 # TGMC
    # 4447 # event-us
    # 4337 # event-eu
    7337 # Effigy
    7777 # event-us (idk ask scriptis)
    8085 # Coolstation
  ];

  services.haproxy.config =
    "\n\n# ==== LOCAL CONFIG ====\n"
    + builtins.readFile ./haproxy.conf
    + ''

      frontend relay_status from base
        mode http
        bind *:80
        http-request return status 200 content-type text/html lf-string "<!doctype html><html><head><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width,initial-scale=1\"><title>Relay ${config.networking.hostName}</title><style>body{font-family:system-ui,sans-serif;max-width:56rem;margin:4rem auto;padding:0 1.5rem;line-height:1.5}code{padding:.15rem .35rem;background:#f3f4f6;border-radius:.35rem}</style></head><body><h1>Relay ${config.networking.hostName}</h1><p>This relay is reachable and serving traffic.</p><ul><li>Host: ${config.networking.hostName}</li><li>Client IP: %[src]</li><li>Requested Host: %[req.hdr(Host)]</li></ul></body></html>"
    '';
}
