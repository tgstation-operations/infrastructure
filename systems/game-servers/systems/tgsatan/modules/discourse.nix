{
  config,
  ...
}: {
    age.secrets.discourse_smtp = {
    file = ../../secrets/discourse_smtp.age;
    owner = "${config.systemd.services.discourse.serviceConfig.User}";
  };

  age.secrets.discourse_db = {
    file = ../../secrets/discourse_db.age;
    owner = "${config.systemd.services.discourse.serviceConfig.User}";
  };

  age.secrets.discourse_admin = {
    file = ../../secrets/discourse_admin.age;
    owner = "${config.systemd.services.discourse.serviceConfig.User}";
  };

  services.discourse = {
    enable = true;
    database = {
      ignorePostgresqlVersion = true; # We're NOT using postgres 13
      host = "127.0.0.1";
      port = 5432;
      passwordFile = config.age.secrets.discourse_db.file;
    };
    hostname = "forum.tgstation13.org";
    nginx.enable = false;
    backendSettings = {

    };
    admin = {
      email = "forum@tgstation13.org";
      username = "tgstation";
      fullName = "Kadence Kelley"; # ;)
      passwordFile = age.secrets.discourse_admin.file;
    };
    mail = {
      contactEmailAddress = "forum@tgstation13.org";
      notificationEmailAddress = "forum_notification@tgstation13.org";
      outgoing = {
        authentication = "login";
        domain = "tgstation13.org";
        enableStartTLSAuto = true;
        forceTLS = true;
        serverAddress = "email-smtp.us-east-1.amazonaws.com";
        port = 587;
        username = "AKIAQXPZC5MPJRHMR3VE";
        passwordFile = config.age.secrets.discourse_smtp.file;
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
      port = config.services.dragonflydb.port;
    };
    secretKeyBaseFile = "/persist/discourse/key"; # has to be a string
    plugins = with config.services.discourse.package.plugins; [
      discourse-canned-replies
      # discourse-github # Soon?
      discourse-prometheus
    ];
  };
}
