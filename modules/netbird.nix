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
      # The module overwrites only the keys it is given in the daemon's
      # config.json, so a host where DNS was once disabled keeps it disabled.
      config.DisableDNS = false;
    };
  };

  # Each daemon hands resolved its own domain on its own link, tg.internal on
  # NetBird's, where without it both would rewrite resolv.conf.
  services.resolved.enable = true;

  # The daemon reads this file only in its preStart, and nixpkgs gives the unit
  # no trigger on it, so a change to the config above would otherwise wait for
  # the next restart.
  systemd.services.netbird.restartTriggers = [config.environment.etc."netbird/config.d/50-nixos.json".source];

  # The login unit polls the daemon until it reports connected, with no limit,
  # and a switch waits for it, so an unreachable management server would hold
  # a deploy forever.
  systemd.services.netbird-login.serviceConfig.TimeoutStartSec = "2min";
}
