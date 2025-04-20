{
  config,
  pkgs,
  lib,
  fenix,
  nixpkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    rclone
  ];

  # `<instance>/Configuration/EventScripts` is symlinked to these directories
  environment.etc."tgs-EventScripts.d" = {
    tg = {
      "DreamDaemonPreLaunch.sh" = {
        text = (builtins.readFile ./tg/DreamDaemonPreLaunch.sh);
        group = "tgstation-server";
        mode = "0755";
      };
      "parse-server.sh" = {
        text = (builtins.readFile ./tg/parse-server.sh);
        group = "tgstation-server";
        mode = "0755";
      };
      "PostCompile.sh" = {
        text = (builtins.readFile ./tg/PostCompile.sh);
        group = "tgstation-server";
        mode = "0755";
      };
      "PreCompile.sh" = {
        text = (builtins.readFile ./tg/PreCompile.sh);
        group = "tgstation-server";
        mode = "0755";
      };
      "tg-Roundend.sh" = {
        text = (builtins.readFile ./tg/tg-Roundend.sh);
        group = "tgstation-server";
        mode = "0755";
      };
      "update-config.sh" = {
        text = (builtins.readFile ./tg/update-config.sh);
        group = "tgstation-server";
        mode = "0755";
      };
    };
    tgmc = {
      "DreamDaemonPreLaunch.sh" = {
        text = (builtins.readFile ./tgmc/DreamDaemonPreLaunch.sh);
        group = "tgstation-server";
        mode = "0755";
      };
      "PostCompile.sh" = {
        text = (builtins.readFile ./tgmc/PostCompile.sh);
        group = "tgstation-server";
        mode = "0755";
      };
      "PreCompile.sh" = {
        text = (builtins.readFile ./tgmc/PreCompile.sh);
        group = "tgstation-server";
        mode = "0755";
      };
      "tg-Roundend.sh" = {
        text = (builtins.readFile ./tgmc/tg-Roundend.sh);
        group = "tgstation-server";
        mode = "0755";
      };
      "update-config.sh" = {
        text = (builtins.readFile ./tgmc/update-config.sh);
        group = "tgstation-server";
        mode = "0755";
      };
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
  };
  services.tgstation-server = {
    enable = true;
    production-appsettings = ./tgs_config.yml;
    home-directory = "/persist/tgs-data";
    # environmentFile =  # Required, add to host config to specify the database URI
    extra-path = lib.makeBinPath (
      with pkgs; [
        fenix.packages.i686-linux.stable.completeToolchain
        nixpkgs.legacyPackages.i686-linux.llvmPackages.clangUseLLVM
        pkg-config
        git
        nodejs_22
        dotnetCorePackages.sdk_8_0
        curl
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
