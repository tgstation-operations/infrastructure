{
  pkgs,
  inputs,
}: let
  inherit (inputs.self.colmena.meta) specialArgs;
  inherit (specialArgs.tg-globals) tgs;
  package = pkgs.callPackage ../packages/tgstation-server/package.nix {};
in
  pkgs.testers.runNixOSTest {
    name = "tgstation-server";
    node.specialArgs = {inherit (specialArgs) nixpkgs;};

    nodes.machine = {
      config,
      lib,
      ...
    }: let
      cfg = config.services.tgstation-server;
    in {
      imports = [
        ../../modules/maria.nix
        ../../systems/game-servers/modules/tgs/service.nix
      ];

      virtualisation = {
        memorySize = 4096;
        cores = 2;
      };

      services.mysql.initialScript = pkgs.writeText "tgs-database.sql" ''
        CREATE DATABASE tgs;
        CREATE USER 'tgs'@'localhost' IDENTIFIED BY 'tgs';
        GRANT ALL PRIVILEGES ON tgs.* TO 'tgs'@'localhost';
      '';

      services.tgstation-server = {
        enable = true;
        home-directory = tgs.root-path;
        environmentFile = pkgs.writeText "tgs.env" ''
          Database__ConnectionString=Server=127.0.0.1;Port=3306;Database=tgs;User ID=tgs;Password=tgs
        '';
        production-appsettings = pkgs.writeText "tgs_config.yml" (lib.generators.toYAML {} {
          Database = {
            DatabaseType = "MariaDB";
            ResetAdminPassword = false;
          };
          General = {
            ConfigVersion = "5.5.0";
            HostApiDocumentation = true;
            PrometheusPort = 5001;
            ValidInstancePaths = [
              tgs.instances-path
            ];
          };
          FileLogging = {
            Disable = false;
            LogLevel = "Trace";
          };
          Kestrel = {
            Endpoints = {
              Http = {
                Url = "http://localhost:${tgs.port}";
              };
            };
          };
          ControlPanel = {
            Enable = true;
            AllowAnyOrigin = true;
          };
          Swarm = {
            UpdateRequiredNodeCount = 2;
          };
        });
      };

      # On first start the watchdog downloads the server host from GitHub into
      # its home. ServerConsole.zip carries the same host under lib/Default, so
      # it is put there instead, as the VM has no network.
      systemd.services.tgstation-server-host-seed = {
        wantedBy = ["tgstation-server.service"];
        before = ["tgstation-server.service"];
        unitConfig.ConditionPathExists = "!${cfg.home-directory}/.tgstation-server/lib/Default";
        serviceConfig = {
          Type = "oneshot";
          User = cfg.username;
        };
        script = ''
          ${pkgs.unzip}/bin/unzip -q ${package.serverConsole}/ServerConsole.zip 'lib/Default/*' -d ${cfg.home-directory}/.tgstation-server
        '';
      };
    };

    testScript = ''
      import json
      import shlex


      def api(method, route, body=None, token=None, user=None):
          command = [
              "curl", "-sSf", "-X", method,
              "-H", "Accept: application/json",
              "-H", "User-Agent: tgstation-infrastructure-test",
              "-H", "Api: Tgstation.Server.Api/10.13.0",
          ]
          if token is not None:
              command += ["-H", f"Authorization: Bearer {token}"]
          if user is not None:
              command += ["-u", user]
          if body is not None:
              command += ["-H", "Content-Type: application/json", "-d", json.dumps(body)]
          command.append(f"http://localhost:${tgs.port}/api/{route}")
          return " ".join(shlex.quote(word) for word in command)


      machine.wait_for_unit("tgstation-server.service")
      machine.wait_for_open_port(${tgs.port})

      with subtest("the API reports the packaged version"):
          info = json.loads(machine.succeed(api("GET", "")))
          assert info["version"] == "${package.version}", info
          assert info["validInstancePaths"] == ["${tgs.instances-path}"], info

      with subtest("the default admin logs in"):
          token = json.loads(
              machine.succeed(api("POST", "", user="Admin:ISolemlySwearToDeleteTheDataDirectory"))
          )["bearer"]

      with subtest("an instance is created only under the valid instance path"):
          machine.fail(api("PUT", "Instance", {"name": "outside", "path": "/srv/outside"}, token))
          instance = json.loads(
              machine.succeed(
                  api("PUT", "Instance", {"name": "test", "path": "${tgs.instances-path}/test"}, token)
              )
          )
          assert instance["path"] == "${tgs.instances-path}/test", instance
          machine.succeed("test -d ${tgs.instances-path}/test")
          machine.succeed("mysql -N -e 'SELECT Name FROM Instances' tgs | grep -x test")
    '';
  }
