{config, ...}: {
  services.authentik = {
    enable = true;
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
