{
  config,
  pkgs-unstable,
  tg-globals,
  ...
}: {
  services.netbird = {
    enable = true;
    package = pkgs-unstable.netbird;
    clients.default = {
      environment.NB_MANAGEMENT_URL = "https://${tg-globals.netbird.domain}";
      login = {
        enable = true;
        setupKeyFile = config.age.secrets.netbird-setup-key.path;
      };
      # tg.lan still resolves through tailscale, and both daemons would rewrite
      # resolv.conf under NetworkManager.
      config.DisableDNS = true;
    };
  };

  # The login unit polls the daemon until it reports connected, with no limit,
  # and a switch waits for it, so an unreachable management server would hold
  # a deploy forever.
  systemd.services.netbird-login.serviceConfig.TimeoutStartSec = "2min";
}
