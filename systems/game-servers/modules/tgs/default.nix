{
  config,
  pkgs,
  lib,
  fenix,
  tg-globals,
  ...
}: let
  # Common environment variables for 32-bit cross-compilation
  tgs-env-vars = {
    CC_i686_unknown_linux_gnu = "${pkgs.pkgsi686Linux.stdenv.cc}/bin/cc";
    CXX_i686_unknown_linux_gnu = "${pkgs.pkgsi686Linux.stdenv.cc}/bin/c++";
    CARGO_TARGET_I686_UNKNOWN_LINUX_GNU_LINKER = "${pkgs.pkgsi686Linux.stdenv.cc}/bin/cc";
    TARGET_CC = "${pkgs.pkgsi686Linux.stdenv.cc}/bin/cc";
    TARGET_CXX = "${pkgs.pkgsi686Linux.stdenv.cc}/bin/c++";
    PKG_CONFIG_PATH_i686_unknown_linux_gnu = lib.makeSearchPath "lib/pkgconfig" (with pkgs.pkgsi686Linux; [
      openssl.dev
      zlib.dev
      mariadb
      sqlite.dev
    ]);
    # bindgen runs on the host arch, so LIBCLANG_PATH must point at host libclang.
    LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
    # Tell bindgen to parse headers for the i686 target when cross-compiling.
    # Cargo normalises hyphens to underscores when looking up env vars, so only
    # the underscore form is needed (and it's the only form bash can export).
    BINDGEN_EXTRA_CLANG_ARGS_i686_unknown_linux_gnu = "--target=i686-unknown-linux-gnu";
  };

  tgs-env-setup = lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "export ${k}=\"${v}\"") tgs-env-vars);

  inject-env-after-shebang = script: let
    lines = lib.splitString "\n" script;
    first-line = lib.head lines;
    remaining-lines = lib.tail lines;
    rest = lib.concatStringsSep "\n" remaining-lines;
  in
    if lib.hasPrefix "#!" first-line
    then "${first-line}\n${tgs-env-setup}\n${rest}"
    else "#!/usr/bin/env bash\n${tgs-env-setup}\n${script}";
in {
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
      text = inject-env-after-shebang (builtins.readFile ./EventScripts/tg/PreCompile.sh);
      group = "tgstation-server";
      mode = "0755";
    };
    "tgs-EventScripts.d/tg/RepoFetch.sh" = {
      source = pkgs.replaceVars ./EventScripts/tg/RepoFetch.sh {
        NIX_GH_PATH = "${pkgs.gh}";
      };
      group = config.services.tgstation-server.groupname;
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
      text = inject-env-after-shebang (builtins.readFile ./EventScripts/tgmc/PreCompile.sh);
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
      text = inject-env-after-shebang (builtins.readFile ./EventScripts/effigy/PreCompile.sh);
      group = "tgstation-server";
      mode = "0755";
    };
    "tgs-EventScripts.d/effigy/RepoFetch.sh" = {
      source = pkgs.replaceVars ./EventScripts/effigy/RepoFetch.sh {
        NIX_GH_PATH = "${pkgs.gh}";
      };
      group = config.services.tgstation-server.groupname;
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
      text = inject-env-after-shebang (builtins.readFile ./EventScripts/cool/PreCompile.sh);
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
    production-appsettings = pkgs.writeText "tgs_config.yml" (lib.generators.toYAML {} (import ./appsettings.nix {inherit tg-globals;}));
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

  systemd.services.tgstation-server.environment = tgs-env-vars;
  # agenix decrypts to the same path whatever the secret holds, so the
  # encrypted file is what changes with it.
  systemd.services.tgstation-server.restartTriggers = [config.age.secrets.tgs.file];
  age.secrets.rsc-cdn = {
    file = ../../secrets/rsc-cdn.age;
    owner = "${config.services.tgstation-server.username}";
    group = "${config.services.tgstation-server.groupname}";
  };
}
