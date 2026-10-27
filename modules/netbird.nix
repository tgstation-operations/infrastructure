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
      # The daemon reads the URL only from its config, and with none there it
      # logs in to NetBird's cloud on first start, before the login unit runs.
      config.ManagementURL = {
        Scheme = "https";
        Host = "${tg-globals.netbird.domain}:443";
      };
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
