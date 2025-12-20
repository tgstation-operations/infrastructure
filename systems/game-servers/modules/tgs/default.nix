{
  config,
  pkgs,
  lib,
  fenix,
  nixpkgs,
  tg-globals,
  ...
}: {
  environment.systemPackages = with pkgs; [
    rclone
  ];

  # `<instance>/Configuration/EventScripts` is symlinked to these directories
  environment.etc = {
    #TG
    "tgs-EventScripts.d/tg/DreamDaemonPreLaunch.sh" = {
      text = builtins.readFile ./EventScripts/tg/DreamDaemonPreLaunch.sh;
      group = "tgstation-server";
      mode = "0755";
    };
    "tgs-EventScripts.d/tg/parse-server.sh" = {
      text = builtins.readFile ./EventScripts/tg/parse-server.sh;
      group = "tgstation-server";
      mode = "0755";
    };
    "tgs-EventScripts.d/tg/PostCompile.sh" = {
      text = builtins.readFile ./EventScripts/tg/PostCompile.sh;
      group = "tgstation-server";
      mode = "0755";
    };
    "tgs-EventScripts.d/tg/PreCompile.sh" = {
      text = builtins.readFile ./EventScripts/tg/PreCompile.sh;
      group = "tgstation-server";
      mode = "0755";
    };
    "tgs-EventScripts.d/tg/tg-Roundend.sh" = {
      text = builtins.readFile ./EventScripts/tg/tg-Roundend.sh;
      group = "tgstation-server";
      mode = "0755";
    };
    "tgs-EventScripts.d/tg/update-config.sh" = {
      text = builtins.readFile ./EventScripts/tg/update-config.sh;
      group = "tgstation-server";
      mode = "0755";
    };

    #TGMC
    "tgs-EventScripts.d/tgmc/DreamDaemonPreLaunch.sh" = {
      text = builtins.readFile ./EventScripts/tgmc/DreamDaemonPreLaunch.sh;
      group = "tgstation-server";
      mode = "0755";
    };
    "tgs-EventScripts.d/tgmc/PostCompile.sh" = {
      text = builtins.readFile ./EventScripts/tgmc/PostCompile.sh;
      group = "tgstation-server";
      mode = "0755";
    };
    "tgs-EventScripts.d/tgmc/PreCompile.sh" = {
      text = builtins.readFile ./EventScripts/tgmc/PreCompile.sh;
      group = "tgstation-server";
      mode = "0755";
    };
    "tgs-EventScripts.d/tgmc/tg-Roundend.sh" = {
      text = builtins.readFile ./EventScripts/tgmc/tg-Roundend.sh;
      group = "tgstation-server";
      mode = "0755";
    };
    "tgs-EventScripts.d/tgmc/update-config.sh" = {
      text = builtins.readFile ./EventScripts/tgmc/update-config.sh;
      group = "tgstation-server";
      mode = "0755";
    };

    #EFFIGY
    "tgs-EventScripts.d/effigy/DreamDaemonPreLaunch.sh" = {
      text = builtins.readFile ./EventScripts/effigy/DreamDaemonPreLaunch.sh;
      group = "tgstation-server";
      mode = "0755";
    };
    "tgs-EventScripts.d/effigy/PostCompile.sh" = {
      text = builtins.readFile ./EventScripts/effigy/PostCompile.sh;
      group = "tgstation-server";
      mode = "0755";
    };
    "tgs-EventScripts.d/effigy/PreCompile.sh" = {
      text = builtins.readFile ./EventScripts/effigy/PreCompile.sh;
      group = "tgstation-server";
      mode = "0755";
    };
    "tgs-EventScripts.d/effigy/tg-Roundend.sh" = {
      text = builtins.readFile ./EventScripts/effigy/tg-Roundend.sh;
      group = "tgstation-server";
      mode = "0755";
    };
    "tgs-EventScripts.d/effigy/update-config.sh" = {
      text = builtins.readFile ./EventScripts/effigy/update-config.sh;
      group = "tgstation-server";
      mode = "0755";
    };

    #COOLSTATION
    "tgs-EventScripts.d/cool/DreamDaemonPreLaunch.sh" = {
      text = builtins.readFile ./EventScripts/cool/DreamDaemonPreLaunch.sh;
      group = "tgstation-server";
      mode = "0755";
    };
    "tgs-EventScripts.d/cool/PostCompile.sh" = {
      text = builtins.readFile ./EventScripts/cool/PostCompile.sh;
      group = "tgstation-server";
      mode = "0755";
    };
    "tgs-EventScripts.d/cool/PreCompile.sh" = {
      text = builtins.readFile ./EventScripts/cool/PreCompile.sh;
      group = "tgstation-server";
      mode = "0755";
    };
    "tgs-EventScripts.d/cool/cool-exciting-roundend.sh" = {
      text = builtins.readFile ./EventScripts/cool/cool-exciting-roundend.sh;
      group = "tgstation-server";
      mode = "0755";
    };
    "tgs-EventScripts.d/cool/update-config.sh" = {
      text = builtins.readFile ./EventScripts/cool/update-config.sh;
      group = "tgstation-server";
      mode = "0755";
    };
  };

  # Secrets used by the game servers
  age.secrets = {
    tg13-comms = {
      file = ../../secrets/tg13-comms.age;
      owner = "${config.services.tgstation-server.username}";
      group = "${config.services.tgstation-server.groupname}";
    };
    tg13-dbconfig = {
      file = ../../secrets/tg13-dbconfig.age;
      owner = "${config.services.tgstation-server.username}";
      group = "${config.services.tgstation-server.groupname}";
    };
    tg13-tts_secrets = {
      file = ../../secrets/tg13-tts_secrets.age;
      owner = "${config.services.tgstation-server.username}";
      group = "${config.services.tgstation-server.groupname}";
    };
    tg13-webhooks = {
      file = ../../secrets/tg13-webhooks.age;
      owner = "${config.services.tgstation-server.username}";
      group = "${config.services.tgstation-server.groupname}";
    };
    tg13-extra_config-rclone = {
      file = ../../secrets/tg13-extra_config-rclone.age;
      owner = "${config.services.tgstation-server.username}";
      group = "${config.services.tgstation-server.groupname}";
    };
    tgmc-dbconfig = {
      file = ../../secrets/tgmc-dbconfig.age;
      owner = "${config.services.tgstation-server.username}";
      group = "${config.services.tgstation-server.groupname}";
    };
    tgmc-tts_secrets = {
      file = ../../secrets/tgmc-tts_secrets.age;
      owner = "${config.services.tgstation-server.username}";
      group = "${config.services.tgstation-server.groupname}";
    };
    tgmc-extra_config-rclone = {
      file = ../../secrets/tgmc-extra_config-rclone.age;
      owner = "${config.services.tgstation-server.username}";
      group = "${config.services.tgstation-server.groupname}";
    };
    effigy-comms = {
      file = ../../secrets/effigy-comms.age;
      owner = "${config.services.tgstation-server.username}";
      group = "${config.services.tgstation-server.groupname}";
    };
    effigy-dbconfig = {
      file = ../../secrets/effigy-dbconfig.age;
      owner = "${config.services.tgstation-server.username}";
      group = "${config.services.tgstation-server.groupname}";
    };
    #effigy-tts_secrets = { for a rainy day...
      #file = ../../secrets/effigy-tts_secrets.age;
      #owner = "${config.services.tgstation-server.username}";
      #group = "${config.services.tgstation-server.groupname}";
    #};
    effigy-extra_config-rclone = {
      file = ../../secrets/effigy-extra_config-rclone.age;
      owner = "${config.services.tgstation-server.username}";
      group = "${config.services.tgstation-server.groupname}";
    };
    cool-apitoken = {
      file = ../../secrets/cool-apitoken.age;
      owner = "${config.services.tgstation-server.username}";
      group = "${config.services.tgstation-server.groupname}";
    };
  };
  services.tgstation-server = {
    enable = true;
    production-appsettings = pkgs.writeText "tgs_config.yml" (lib.generators.toYAML {} {
      Database = {
        DatabaseType = "MariaDB";
        ResetAdminPassword = false;
      };
      General = {
        ConfigVersion = "5.5.0";
        # GitHubAccessToken = TODO;
        HostApiDocumentation = true;
        PrometheusPort = 5001;
        ValidInstancePaths = [
          tg-globals.tgs.instances-path
        ];
      };
      FileLogging = {
        Disable = false;
        LogLevel = "Trace";
      };
      Kestrel = {
        Endpoints = {
          Http = {
            Url = "http://localhost:${tg-globals.tgs.port}";
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
      Security = {
        OidcStrictMode = true;
        OpenIDConnect = {
          Auth = {
            Authority = "https://auth.tgstation13.org/application/o/tgstation-server";
            ClientId = "YDKw6NpQtKp6KHONGXfjuL4OhdhWVgCj0xIqwQ4z";
            FriendlyName = "/tg/ Identity";
            ThemeIconUrl = "https://tgstation13.org/assets/img/favicon.ico";
          };
        };
      };
    });
    home-directory = tg-globals.tgs.root-path;
    # environmentFile =  # Required, add to host config to specify the database URI
    extra-path = lib.makeBinPath (
      with pkgs; [
        (with fenix.packages.x86_64-linux; combine [minimal.toolchain targets.i686-unknown-linux-gnu.minimal.rust-std])
        clangMultiStdenv.cc
        llvmPackages.libclang
        which
        pkg-config
        git
        nodejs_22
        bun
        dotnetCorePackages.sdk_8_0
        pkgsi686Linux.curl # DD needs 32 bit libcurl since 516.1664
        gnutar
        gzip
        coreutils # md5sum, for RSC
        zip # For RSC
        rclone
        yt-dlp # For Internet Sounds
        lua # Lua Support
      ]
    );
  };
  age.secrets.rsc-cdn = {
    file = ../../secrets/rsc-cdn.age;
    owner = "${config.services.tgstation-server.username}";
    group = "${config.services.tgstation-server.groupname}";
  };
}
