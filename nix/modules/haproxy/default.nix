{
  config,
  lib,
  nodes,
  pkgs,
  ...
}: let
  cfg = config.tgstation.haproxy;
  isRelay = cfg.relay-for != [];
  isGameServer = cfg.games != {};

  # The game server's HAProxy connects to DreamDaemon here, from the player's
  # address, and DreamDaemon's replies from here are routed back into it.
  byond = "10.248.1.1";
  proxyPort = port: port + 10000;

  relayed = lib.concatMap (host: let
    server = nodes.${host}.config.tgstation.haproxy;
  in
    lib.mapAttrsToList (name: port: {
      inherit name port host;
      inherit (server) address;
    })
    server.games)
  cfg.relay-for;
in {
  options.tgstation.haproxy = {
    interface = lib.mkOption {
      type = lib.types.str;
      default = "tailscale0";
      description = "The overlay network's interface, over which relays reach game servers and monitoring reaches HAProxy.";
    };

    games = lib.mkOption {
      type = lib.types.attrsOf lib.types.port;
      default = {};
      example = {sybil = 1337;};
      description = ''
        The DreamDaemon port of each game this host runs. Relays take players on
        the same port and pass them on, over the overlay with the PROXY
        protocol, to the port 10000 above it here.
      '';
    };

    address = lib.mkOption {
      type = lib.types.str;
      description = "This game server's address on the overlay, which relays connect to.";
    };

    relay-for = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = ["tgsatan"];
      description = "The game servers, by node name, whose games this relay takes players for.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (isRelay || isGameServer) {
      systemd.tmpfiles.rules = [
        "d /var/lib/haproxy 770 ${config.services.haproxy.user} ${config.services.haproxy.group}"
      ];
      services.haproxy.enable = true;
      systemd.services.haproxy = {
        serviceConfig = {
          AmbientCapabilities = lib.mkForce "CAP_NET_BIND_SERVICE CAP_NET_RAW";
          CapabilityBoundingSet = "CAP_NET_BIND_SERVICE CAP_NET_RAW";
        };
        environment = {
          PROMETHEUS_PORT = "8405";
        };
      };

      # The stats and metrics frontends bind every address, so haproxy starts
      # whether or not the overlay is up, and only the overlay may reach them.
      networking.firewall.interfaces.${cfg.interface}.allowedTCPPorts = [
        8888
        (lib.toInt config.systemd.services.haproxy.environment.PROMETHEUS_PORT)
      ];
    })

    (lib.mkIf isRelay {
      services.haproxy.config =
        builtins.readFile ./relay.conf
        + lib.concatMapStrings (game: ''

          frontend ${game.name}in from incoming-byond
            bind *:${toString game.port}
            default_backend ${game.name}out
          backend ${game.name}out from outgoing-byond
            server ${game.host} ${game.address}:${toString (proxyPort game.port)}
        '')
        relayed;

      networking.firewall.allowedTCPPorts = map (game: game.port) relayed;
    })

    (lib.mkIf isGameServer {
      services.haproxy.config =
        builtins.readFile ./game-server.conf
        + lib.concatStrings (lib.mapAttrsToList (name: port: ''

            frontend ${name}in from proxy
              bind *:${toString (proxyPort port)} accept-proxy
              default_backend ${name}out
            backend ${name}out from byond
              server ${name} ${byond}:${toString port}
          '')
          cfg.games);

      networking.firewall.interfaces.${cfg.interface}.allowedTCPPorts = map proxyPort (lib.attrValues cfg.games);

      services.tailscale.useRoutingFeatures = lib.mkForce "both"; # IP Forwarding

      networking.iproute2 = {
        enable = true;
        rttablesExtraConfig = "100 haproxy";
      };

      networking.interfaces.lo.ipv4 = {
        addresses = [
          {
            address = byond;
            prefixLength = 24;
          }
        ];
        routes = [
          {
            address = "0.0.0.0";
            prefixLength = 0;
            options = {
              table = "haproxy";
            };
          }
        ];
      };

      # nixpkgs 26.05 dropped network.target from network-addresses-lo's wantedBy and
      # relies on a udev add event instead, which never fires for lo. Without this
      # nothing starts it, 10.248.1.1 never appears and every backend check fails.
      systemd.services.network-addresses-lo = {
        wantedBy = ["network.target"];
        before = ["network.target"];
      };

      systemd.services.haproxy-iproute2 = {
        wantedBy = ["multi-user.target"];
        after = ["network.target"];
        description = "iproute2 rule for haproxy";
        path = [pkgs.bash pkgs.iproute2];
        script = ''
          # Tell traffic from this range to use a custom routing table
          ip rule add from 10.248.1.0/24 lookup 100 prio 50 || echo "Skipped rule setup"
        '';
        serviceConfig = {
          Type = "oneshot";
          User = "root";
          Restart = "no";
        };
      };
    })
  ];
}
