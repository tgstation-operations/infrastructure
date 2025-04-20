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
  environment.etc."tgs-EventScripts.d/tg" = {
    #TG
    "tgs-EventScripts.d/tg/DreamDaemonPreLaunch.sh" = {
      text = (builtins.readFile ./EventScripts/tg/DreamDaemonPreLaunch.sh);
      group = "tgstation-server";
      mode = "0755";
    };
    "tgs-EventScripts.d/tg/parse-server.sh" = {
      text = (builtins.readFile ./EventScripts/tg/parse-server.sh);
      group = "tgstation-server";
      mode = "0755";
    };
    "tgs-EventScripts.d/tg/PostCompile.sh" = {
      text = (builtins.readFile ./EventScripts/tg/PostCompile.sh);
      group = "tgstation-server";
      mode = "0755";
    };
    "tgs-EventScripts.d/tg/PreCompile.sh" = {
      text = (builtins.readFile ./EventScripts/tg/PreCompile.sh);
      group = "tgstation-server";
      mode = "0755";
    };
    "tgs-EventScripts.d/tg/tg-Roundend.sh" = {
      text = (builtins.readFile ./EventScripts/tg/tg-Roundend.sh);
      group = "tgstation-server";
      mode = "0755";
    };
    "tgs-EventScripts.d/tg/update-config.sh" = {
      text = (builtins.readFile ./EventScripts/tg/update-config.sh);
      group = "tgstation-server";
      mode = "0755";
    };

    #TGMC
    "tgs-EventScripts.d/tgmc/DreamDaemonPreLaunch.sh" = {
      text = (builtins.readFile ./EventScripts/tgmc/DreamDaemonPreLaunch.sh);
      group = "tgstation-server";
      mode = "0755";
    };
    "tgs-EventScripts.d/tgmc/PostCompile.sh" = {
      text = (builtins.readFile ./EventScripts/tgmc/PostCompile.sh);
      group = "tgstation-server";
      mode = "0755";
    };
    "tgs-EventScripts.d/tgmc/PreCompile.sh" = {
      text = (builtins.readFile ./EventScripts/tgmc/PreCompile.sh);
      group = "tgstation-server";
      mode = "0755";
    };
    "tgs-EventScripts.d/tgmc/tg-Roundend.sh" = {
      text = (builtins.readFile ./EventScripts/tgmc/tg-Roundend.sh);
      group = "tgstation-server";
      mode = "0755";
    };
    "tgs-EventScripts.d/tgmc/update-config.sh" = {
      text = (builtins.readFile ./EventScripts/tgmc/update-config.sh);
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
