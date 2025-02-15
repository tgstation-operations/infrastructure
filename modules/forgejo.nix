{
  config,
  services,
  ...
}: {
  # WIP, poke lorwp in tgs discord with questions
  services.forgejo = {
    enable = true;
    stateDir = "/persist/forgejo";
    useWizard = false;
    lfs.enable = true;
    appName = "tgsatan opsgit";
    settings = {
      server = {
        # <https://forgejo.org/docs/latest/admin/config-cheat-sheet/>
        HTTP_PORT = 9001;
        DOMAIN = "tgsatan.tgstation13.lan";
        PROTOCOL = "http";
        ROOT_URL = "${services.forgejo.settings.server.PROTOCOL}://${services.forgejo.settings.server.DOMAIN}:${services.forgejo.settings.server.HTTP_PORT}";
      };
      DEFAULT = {
        APP_SLOGAN = "Fuck Headmins";
      };
      repository = {
        DEFAULT_PRIVATE = "private"; # Default private when creating a new repository. [last, private, public]
      };
      metrics = {
        ENABLED = true; # Enables /metrics endpoint for prometheus
      };
    };
    database = {
      type = "mysql";
      host = "localhost";
      port = 5432;
      user = "forgejo"; # default
      passwordFile = config.age.secrets.forgejo-mysql.path;
      createDatabase = false;
    };
  };
}
