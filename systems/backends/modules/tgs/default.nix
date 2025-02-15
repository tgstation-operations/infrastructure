{
  config,
  pkgs,
  lib,
  fenix,
  nixpkgs,
  ...
}: let
  fenix-i686 = fenix.packages.i686-linux;
  pkgs-i686 = nixpkgs.legacyPackages.i686-linux;
in {
  environment.systemPackages = with pkgs; [
    dotnetCorePackages.sdk_8_0
    rclone
  ];
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
        git
        nodejs_22
        pkgs-i686.gcc
        pkgs-i686.clang
        pkgs-i686.libclang
        (
          with fenix-i686;
            combine [
              latest.cargo
              stable.rustc
            ]
        )
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
