{
  config,
  pkgs,
  ...
}: let
  socket = config.services.anubis.instances.default.settings.BIND;
in {
  age.secrets.anubis_ed25519_key = {
    file = ../../../secrets/anubis_ed25519_key.age;
    owner = config.services.anubis.instances.default.user;
  };

  services.anubis = {
    package = pkgs.callPackage ../../../../../nix/packages/anubis/package.nix {};
    instances.default = {
      settings = {
        # A blank target has Anubis answer Caddy's forward_auth rather than
        # proxy, and it sends every challenge to tgstation13.org, whose cookie
        # covers the other sites.
        TARGET = " ";
        PUBLIC_URL = "https://tgstation13.org";
        COOKIE_DOMAIN = "tgstation13.org";
        REDIRECT_DOMAINS = "tgstation13.org,forums.tgstation13.org,wiki.tgstation13.org";
        ED25519_PRIVATE_KEY_HEX_FILE = config.age.secrets.anubis_ed25519_key.path;
      };
      policy = {
        # Discord's link previews claim to be a browser, and Discord publishes
        # no addresses to check them against.
        extraBots = [
          {
            name = "discord-previews";
            user_agent_regex = "Discordbot/";
            action = "ALLOW";
          }
        ];
        settings = {
          # forward_auth lets any 2xx through, and Anubis denies with a 200 by
          # default.
          status_codes = {
            CHALLENGE = 200;
            DENY = 403;
          };
          thresholds = [
            {
              name = "minimal-suspicion";
              expression = "weight <= 0";
              action = "ALLOW";
            }
            {
              name = "mild-suspicion";
              expression.all = ["weight > 0" "weight < 10"];
              action = "CHALLENGE";
              challenge = {
                algorithm = "metarefresh";
                difficulty = 1;
              };
            }
            {
              name = "moderate-suspicion";
              expression.all = ["weight >= 10" "weight < 20"];
              action = "CHALLENGE";
              challenge = {
                algorithm = "preact";
                difficulty = 1;
              };
            }
            {
              name = "mild-proof-of-work";
              expression.all = ["weight >= 20" "weight < 30"];
              action = "CHALLENGE";
              challenge = {
                algorithm = "fast";
                difficulty = 2;
              };
            }
            {
              name = "extreme-suspicion";
              expression = "weight >= 30";
              action = "CHALLENGE";
              challenge = {
                algorithm = "fast";
                difficulty = 4;
              };
            }
          ];
        };
      };
    };
  };

  users.users.${config.services.caddy.user}.extraGroups = [config.users.groups.anubis.name];

  # The wiki rewrites most requests to /index.php before forward_auth runs, so
  # Anubis gets the original URI to match its rules on and to send the visitor
  # back to. Every site serves Anubis's own pages, for the styles and images of
  # the error pages forward_auth passes on.
  services.caddy.extraConfig = ''
    (anubis) {
      @anubis not path /.within.website/* {args[:]}
      forward_auth @anubis unix/${socket} {
        uri /.within.website/x/cmd/anubis/api/check
        header_up X-Real-IP {client_ip}
        header_up X-Forwarded-Uri {http.request.orig_uri}
      }
      handle /.within.website/* {
        reverse_proxy unix/${socket} {
          header_up X-Real-IP {client_ip}
        }
      }
    }
  '';
}
