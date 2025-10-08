{
  config,
  ...
}: {
  age.secrets.authentik = {
    file = ../../secrets/authentik.age;
    owner = "${config.systemd.services.authentik.serviceConfig.User}";
  };

  services.authentik = {
    enable = true;
    environmentFile = config.age.secrets.authentik.path;
    settings = {
      email = {
        host = "smtp-relay.brevo.com";
        port = 587;
        username = "87ed48001@smtp-brevo.com";
        use_tls = true;
        use_ssl = false;
        from = "noreply@tgstation13.org";
      };
      disable_startup_analytics = true;
      avatars = "gravatar";
    };
  };
}
