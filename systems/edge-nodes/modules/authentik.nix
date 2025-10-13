({authDomain}: {
  config,
  inputs,
  ...
}: {
  imports = [
    self.inputs.authentik-nix.nixosModules.default
  ];
  services.authentik = {
    enable = true;
    createDatabase = true;
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
  security.acme.certs = {
    "${authDomain}" = {};
  };
  services.caddy = {
    virtualHosts = {
      "${authDomain}" = {
        useACMEHost = "${authDomain}";
        extraConfig = ''
          encode gzip zstd
          reverse_proxy localhost:9000
        '';
      };
    };
  };
})
