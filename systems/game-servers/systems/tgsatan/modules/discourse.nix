{
  config,
  ...
}: {
    age.secrets.discourse_smtp = {
    file = ../secrets/discourse_smtp.age;
    owner = "${config.systemd.services.discourse.serviceConfig.User}";
  };

  age.secrets.discourse_db = {
    file = ../secrets/discourse_db.age;
    owner = "${config.systemd.services.discourse.serviceConfig.User}";
  };

  age.secrets.discourse_admin = {
    file = ../secrets/discourse_admin.age;
    owner = "${config.systemd.services.discourse.serviceConfig.User}";
  };

  services.discourse = {
    enable = true;
    database = {
      ignorePostgresqlVersion = true; # We're NOT using postgres 13
      host = "127.0.0.1";
      name = "discourse";
      username = "discourse";
      # Requires a string
      passwordFile = toString config.age.secrets.discourse_db.file;
    };
    hostname = "forum.tgstation13.org";
    nginx.enable = false;
    admin = {
      email = "forum@tgstation13.org";
      username = "tgstation";
      fullName = "Kadence Kelley"; # ;)
      passwordFile = config.age.secrets.discourse_admin.file;
    };
    mail = {
      contactEmailAddress = "forum@tgstation13.org";
      notificationEmailAddress = "noreply@tgstation13.org";
      outgoing = {
        authentication = "login";
        domain = "tgstation13.org";
        enableStartTLSAuto = true;
        forceTLS = true;
        serverAddress = "smtp-relay.brevo.com";
        port = 587;
        username = "87ed48001@smtp-brevo.com";
        # Requires a string
        passwordFile = toString config.age.secrets.discourse_smtp.file;
      };
    };
    siteSettings = {
      required = {
        title = "/tg/staiton 13 Forums";
        site_description = "A place to discuss all things SS13";
      };
    };
    redis = {
      host = "127.0.0.1";
    };
    secretKeyBaseFile = "/persist/discourse/key"; # has to be a string
    plugins = with config.services.discourse.package.plugins; [
      discourse-canned-replies
      # discourse-github # Soon?
      discourse-prometheus
    ];
  };
}
