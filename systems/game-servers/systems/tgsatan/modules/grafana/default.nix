{
  config,
  pkgs,
  ...
}: {
  networking.firewall.allowedTCPPorts = [
    3000
  ];
  networking.firewall.allowedUDPPorts = [
    3000
  ];
  services.grafana = {
    enable = true;
    dataDir  = "/persist/grafana";

    settings = {
      analytics.reporting_enabled = false;

      server = {
        http_addr = "100.64.0.1"; # tailscale IP
        http_port = 3000;
        enforce_domain = false;
        enable_gzip = true;
      };

      database = {
        type = "postgres";
        host = "tgsatan.tg.lan";
        port = config.services.postgres.port;
        user = "grafana";
        password = "$__file{${config.age.secrets.grafana_db.path}}";
      };

      smtp = {
        # TODO
        enabled = false;
        host = "email-smtp.us-east-1.amazonaws.com";
        user = "AKIAQXPZC5MPNBDMISOP";
        password = "$__file{${config.age.secrets.grafana_smtp.path}}";
      };
    };

    declarativePlugins = [
      # Put plugins here
    ];

    provision = {
      # enable = true; # TODO
      datasources = {
        prometheus = {
          type = "prometheus";
          access = "proxy";
          url = "http://tgsatan.tg.lan:9090"; # Change when prometheus is moved
          isDefault = true;
        };
      };
      dashboards.path = "./dashboards"; # TODO
    };
  };

  age.secrets.grafana_smtp.owner = "${systemd.services.grafana.serviceConfig.user}";
}
