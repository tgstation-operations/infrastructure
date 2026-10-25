{
  config,
  lib,
  inputs,
  pkgs-unstable,
  tg-globals,
  ...
}: let
  inherit (tg-globals.netbird) domain;
  issuer = "https://${domain}/oauth2";
  relayAddress = "rels://${domain}:443/relay";
  ownerEmail = "scriptis@tgstation13.org";
  server = config.services.netbird.server;
  relay = config.services.netbird.relay;
  secret = name: {_secret = config.age.secrets.${name}.path;};
  unstableModules = "${inputs.nixpkgs-unstable}/nixos/modules/services/networking/netbird";
  relayModule = import "${unstableModules}/netbird-relay.nix";
in {
  # The server runs nixpkgs-unstable's NetBird, and the dashboard module has to
  # template the placeholders its package ships, so the modules come from there.
  disabledModules = ["services/networking/netbird/server.nix"];
  imports = [
    "${unstableModules}/server.nix"
    # Without its manual page, whose anchors 26.05's manual has no redirects
    # for and refuses to build.
    (lib.setFunctionArgs (args: removeAttrs (relayModule args) ["meta"]) (lib.functionArgs relayModule))
  ];

  age.secrets = {
    netbird-datastore-key.file = ../secrets/netbird-datastore-key.age;
    netbird-idp-cookie-key.file = ../secrets/netbird-idp-cookie-key.age;
    netbird-relay-secret.file = ../secrets/netbird-relay-secret.age;
    netbird-owner-hash.file = ../secrets/netbird-owner-hash.age;
  };

  services.netbird.server = {
    enable = true;
    inherit domain;

    dashboard = {
      package = pkgs-unstable.netbird-dashboard;
      settings = {
        AUTH_AUTHORITY = issuer;
        AUTH_CLIENT_ID = "netbird-dashboard";
        AUTH_AUDIENCE = "netbird-dashboard";
        AUTH_SUPPORTED_SCOPES = "openid profile email groups";
        AUTH_REDIRECT_URI = "/nb-auth";
        AUTH_SILENT_REDIRECT_URI = "/nb-silent-auth";
      };
    };

    signal.package = pkgs-unstable.netbird-signal;

    management = {
      package = pkgs-unstable.netbird-management;
      turnDomain = domain;
      oidcConfigEndpoint = "${issuer}/.well-known/openid-configuration";
      settings = {
        DataStoreEncryptionKey = secret "netbird-datastore-key";
        TURNConfig = {
          Turns = [];
          Secret = null;
        };
        Relay = {
          Addresses = [relayAddress];
          CredentialsTTL = "24h";
          Secret = secret "netbird-relay-secret";
        };
        ReverseProxy.TrustedPeers = ["127.0.0.1/32"];
        DisableDefaultPolicy = true;
        EmbeddedIdP = {
          Enabled = true;
          Issuer = issuer;
          SignKeyRefreshEnabled = true;
          DashboardRedirectURIs = [
            "https://${domain}/nb-auth"
            "https://${domain}/nb-silent-auth"
          ];
          Owner = {
            Email = ownerEmail;
            Hash = secret "netbird-owner-hash";
          };
          SessionCookieEncryptionKey = secret "netbird-idp-cookie-key";
        };
      };
    };
  };

  services.netbird.relay = {
    enable = true;
    package = pkgs-unstable.netbird-relay;
    authSecretFile = config.age.secrets.netbird-relay-secret.path;
    openFirewall = true;
    settings = {
      listen-address = "127.0.0.1:33080";
      exposed-address = relayAddress;
      enable-stun = true;
    };
  };

  security.acme.certs.${domain} = {};
  services.caddy.virtualHosts.${domain} = {
    useACMEHost = domain;
    extraConfig = ''
      handle /signalexchange.SignalExchange/* {
        reverse_proxy h2c://127.0.0.1:${toString server.signal.port}
      }
      handle /management.ManagementService/* {
        reverse_proxy h2c://127.0.0.1:${toString server.management.port}
      }
      @management path /api/* /oauth2/*
      handle @management {
        reverse_proxy 127.0.0.1:${toString server.management.port}
      }
      handle /relay* {
        reverse_proxy ${relay.settings.listen-address}
      }
      handle {
        root * ${server.dashboard.finalDrv}
        try_files {path} {path}.html {path}/ /index.html
        file_server
      }
    '';
  };
}
