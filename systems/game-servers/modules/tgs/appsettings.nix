{tg-globals}: {
  Database = {
    DatabaseType = "MariaDB";
    ResetAdminPassword = false;
  };
  General = {
    ConfigVersion = "5.5.0";
    # GitHubAccessToken = TODO;
    HostApiDocumentation = true;
    PrometheusPort = 5001;
    ValidInstancePaths = [
      tg-globals.tgs.instances-path
    ];
  };
  FileLogging = {
    Disable = false;
    LogLevel = "Trace";
  };
  Kestrel = {
    Endpoints = {
      Http = {
        Url = "http://localhost:${tg-globals.tgs.port}";
      };
    };
  };
  ControlPanel = {
    Enable = true;
    AllowAnyOrigin = true;
  };
  Swarm = {
    UpdateRequiredNodeCount = 2;
  };
  Security = {
    OidcStrictMode = true;
    OpenIDConnect = {
      Auth = {
        Authority = "https://auth.tgstation13.org/application/o/tgstation-server";
        ClientId = "YDKw6NpQtKp6KHONGXfjuL4OhdhWVgCj0xIqwQ4z";
        FriendlyName = "/tg/ Identity";
        ThemeIconUrl = "https://tgstation13.org/assets/img/favicon.ico";
      };
    };
  };
}
