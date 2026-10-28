{pkgs}: let
  port = 1337;

  # Answers the health check's ping as DreamDaemon does, and anything else
  # with the address the connection came from.
  dreamdaemon = pkgs.writers.writePython3 "dreamdaemon" {} ''
    import socketserver
    import struct


    class Topic(socketserver.BaseRequestHandler):
        def handle(self):
            data = self.request.recv(4096)
            if data.startswith(b"\x00\x83"):
                reply = b"\x00\x83\x00\x05\x2a" + struct.pack("<f", 1)
            elif data:
                reply = self.client_address[0].encode() + b"\n"
            else:
                return
            self.request.sendall(reply)


    socketserver.ThreadingTCPServer.allow_reuse_address = True
    server = socketserver.ThreadingTCPServer(("0.0.0.0", ${toString port}), Topic)
    server.serve_forever()
  '';

  # A server that is UP and has passed a check, since servers start UP.
  checkedUp = backend: server: check: "curl -sf 'http://127.0.0.1:8888/;csv' | grep '^${backend},${server},' | grep -F ',UP,' | grep -F ',${check},'";
in
  pkgs.testers.runNixOSTest ({config, ...}: {
    name = "haproxy";

    defaults = {
      imports = [../modules/haproxy];
      networking.nftables.enable = true;
      environment.systemPackages = [pkgs.curl pkgs.netcat-openbsd];
    };

    # vlan 1 stands in for the internet and vlan 2 for the overlay, which, like
    # wt0, is not a trusted interface.
    nodes = {
      client.virtualisation.vlans = [1];

      relay = {
        virtualisation.vlans = [1 2];
        # colmena's nodes are evaluated systems, where the test's are configs.
        _module.args.nodes = pkgs.lib.mkForce (builtins.mapAttrs (_: node: {config = node;}) config.nodes);
        tgstation.haproxy = {
          interface = "eth2";
          relay-for = ["gameserver"];
        };
      };

      gameserver = {config, ...}: {
        virtualisation.vlans = [2];
        tgstation.haproxy = {
          interface = "eth1";
          address = config.networking.primaryIPAddress;
          games.sybil = port;
        };
        systemd.services.dreamdaemon = {
          wantedBy = ["multi-user.target"];
          serviceConfig.ExecStart = dreamdaemon;
        };
      };
    };

    testScript = {nodes, ...}: ''
      start_all()
      gameserver.wait_until_succeeds("${checkedUp "sybilout" "sybil" "L7OK"}")
      relay.wait_until_succeeds("${checkedUp "sybilout" "gameserver" "L4OK"}")

      with subtest("DreamDaemon sees the player's own address, with forwarding off"):
          gameserver.succeed("sysctl -n net.ipv4.conf.all.forwarding | grep -Fx 0")
          client.succeed("echo hi | nc -N -w 5 relay ${toString port} | grep -Fx ${nodes.client.networking.primaryIPAddress}")

      with subtest("metrics are reachable over the overlay, not from outside"):
          relay.succeed("curl -sf http://gameserver:8405/metrics")
          relay.succeed("curl -sf http://127.0.0.1:8405/metrics")
          gameserver.succeed("curl -sf http://${nodes.gameserver.networking.primaryIPAddress}:8405/metrics")
          client.fail("curl -sf --max-time 5 http://relay:8405/metrics")
    '';
  })
