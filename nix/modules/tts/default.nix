{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgstation.tts;
  tgtts = inputs.tgtts-v4.packages.${pkgs.stdenv.hostPlatform.system}.tgtts;
  state = "/var/lib/tgtts";
  shaderCache = "${state}/shader-cache";

  settings = (pkgs.formats.toml {}).generate "tgtts.toml" {
    listen = "0.0.0.0:${toString cfg.port}";
    checkpoint_dir = cfg.checkpoint-dir;
    voices_dir = cfg.voices-dir;
    assets_dir = cfg.assets-dir;
    voice_levels_file = cfg.voice-levels-file;
    metrics_db = "${state}/metrics.sqlite";
    cpu_limit = 8;
    babble_cap = true;
  };
in {
  options.tgstation.tts = {
    port = lib.mkOption {
      type = lib.types.port;
      description = "The port tgtts serves the games on, on every address. The firewall decides which interfaces reach it.";
    };

    token-file = lib.mkOption {
      type = lib.types.externalPath;
      description = "A file holding the token the games send in their Authorization header.";
    };

    checkpoint-dir = lib.mkOption {
      type = lib.types.externalPath;
      description = "The VoxCPM2 checkpoint, openbmb/VoxCPM2 on HuggingFace.";
    };

    voices-dir = lib.mkOption {
      type = lib.types.externalPath;
      description = "The voices, as tgtts-v4's convert-voices writes them.";
    };

    assets-dir = lib.mkOption {
      type = lib.types.externalPath;
      description = "The radio's clicks and static and the silicon effect's impulse responses.";
    };

    voice-levels-file = lib.mkOption {
      type = lib.types.externalPath;
      description = "How loud each of these voices comes out of this checkpoint, as tgtts-gains writes it.";
    };
  };

  config = {
    # tgtts loads NVIDIA's Vulkan driver from /run/opengl-driver.
    hardware.graphics.enable = true;

    systemd.services.tgtts = {
      description = "tgstation TTS";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      # systemd orders a DynamicUser's state after the mounts for the path it
      # is named by, /var/lib/tgtts, but keeps it in /var/lib/private.
      unitConfig.RequiresMountsFor = "/var/lib/private/tgtts";
      # Restarted after a switch's activation rather than stopped before it,
      # speech is down only for its own start, not for the activation too.
      stopIfChanged = false;
      environment = {
        TGTTS_TOKEN_FILE = "%d/token";
        # NVIDIA's driver keeps the pipelines it compiled here, and a start that
        # finds them takes 12 s rather than 47.
        __GL_SHADER_DISK_CACHE_PATH = shaderCache;
        __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
        XDG_CACHE_HOME = shaderCache;
      };
      serviceConfig = {
        Type = "exec";
        ExecStart = "${lib.getExe' tgtts "tgtts"} ${settings}";
        Restart = "on-failure";
        RestartSec = 5;
        LoadCredential = "token:${cfg.token-file}";
        DynamicUser = true;
        StateDirectory = ["tgtts" "tgtts/shader-cache"];
        # Below the game servers, whose CPUs it shares.
        Nice = 10;

        # PrivateDevices would hide the GPU, so the device cgroup narrows what
        # it reaches to the GPU instead.
        DevicePolicy = "closed";
        DeviceAllow = ["char-drm" "char-nvidia" "char-nvidia-caps" "char-nvidia-uvm"];
        CapabilityBoundingSet = "";
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX"];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        SystemCallArchitectures = "native";
        UMask = "0077";
      };
    };
  };
}
