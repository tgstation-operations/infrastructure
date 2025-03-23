{
  config,
  pkgs,
  ...
}: {
  age.secrets.grafana_smtp = {
    file = ../../secrets/grafana_smtp.age;
    owner = "${config.systemd.services.grafana.serviceConfig.User}";
  };

  age.secrets.grafana_db = {
    file = ../../secrets/grafana_db.age;
    owner = "${config.systemd.services.grafana.serviceConfig.User}";
  };

  age.secrets.grafana_admin = {
    file = ../../secrets/grafana_admin.age;
    owner = "${config.systemd.services.grafana.serviceConfig.User}";
  };

  services.grafana = {
    enable = true;
    dataDir = "/persist/grafana";

    settings = {
      analytics.reporting_enabled = false;

      security = {
        admin_email = "admin@tgstation13.org";
        admin_username = "admin";
        admin_password = "$__file{${config.age.secrets.grafana_admin.path}}";
        strict_transport_security = true;
      };

      server = {
        http_addr = "100.64.0.1"; # tailscale IP
        http_port = 3000;
        protocol = "https";
        enforce_domain = false;
        enable_gzip = true;
        domain = "tgsatan.tg.lan";
        cookie_secure = true;
      };

      database = {
        type = "postgres";
        host = "127.0.0.1"; # Currently ran on tgsatan
        port = config.services.postgresql.settings.port;
        user = "grafana";
        password = "$__file{${config.age.secrets.grafana_db.path}}";
      };

      smtp = {
        enabled = true;
        host = "email-smtp.us-east-1.amazonaws.com";
        user = "AKIAQXPZC5MPNBDMISOP";
        password = "$__file{${config.age.secrets.grafana_smtp.path}}";
        from_address = "noreply@tgstation13.org";
      };
    };

    declarativePlugins = [
      # Put plugins here
    ];

    provision = {
      # enable = true; # TODO
      datasources.settings.datasources = [
        {
          name = "prometheus";
          type = "prometheus";
          access = "proxy";
          url = "http://tgsatan.tg.lan:9090"; # Change when prometheus is moved
          isDefault = true; # dead var?
        }
        {
          name = "loki";
          type = "loki";
          proxy = "proxy";
          url = "http://tgsatan.tg.lan:3100";
        }
      ];

      dashboards.path = ./dashboards; # TODO
    };
  };
}
