{
  config,
  pkgs,
  lib,
  self,
  ...
}: let
  hw = self.inputs.nixos-hardware.nixosModules;
  baseModules = [
    (import hw.common-gpu-nvidia)
    (import hw.common-cpu-amd)
    self.inputs.tgstation-server.nixosModules.default
  ];
  localModules = [
    ../../../../modules/fail2ban.nix
    ../../../../modules/maria.nix
    ../../../../modules/openssh.nix
    ../../../../modules/tailscale.nix
    ../../modules/garage.nix
    ../../modules/motd.nix
    ../../modules/muffin-button.nix
    ../../modules/docker.nix
    ../../modules/tgs
    (import ../../modules/cloudflared.nix {
      inherit pkgs config;
      age-file = ./secrets/cloudflared.age;
    })
    ./modules/atticd.nix
    ./modules/cockroachdb
    ./modules/grafana
    ./modules/postgres.nix
    ./modules/monitoring
    ./modules/motd
    ./modules/nvidia.nix
    ./modules/redbot.nix
  ];
in {
  networking.hostName = "tgsatan";
  networking.hostId = "8f33c04a";
  system.stateVersion = "24.05";

  imports =
    baseModules
    ++ localModules
    ++ [
      ./disko.nix
      ./raw-logs.nix
      ./modules/haproxy
      ./modules/caddy
    ];

  hardware.nvidia-container-toolkit.enable = true;

  programs.nix-ld.enable = true;

  boot = {
    supportedFilesystems = ["zfs"];
    zfs.package = pkgs.zfs;
    loader.systemd-boot.enable = true;
  };

  programs.fuse.userAllowOther = true;

  environment.persistence."/persist/system" = {
    hideMounts = false;

    directories = [
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/lib/tailscale"
      "/etc/NetworkManager/system-connections"
      "/var/lib/acme"
      "/var/lib/postgresql"
    ];
  };

  boot.initrd.postResumeCommands = lib.mkAfter ''
    zfs rollback -r zroot/root@blank
  '';

  fileSystems."/persist" = {
    neededForBoot = true;
  };

  networking.hosts = {
    "127.0.0.1" = ["manuel.tgstation13.org" "sybil.tgstation13.org" "tgsatan.us.tgstation13.org" "tgs.tgsatan.us.tgstation13.org" "s3.tgsatan.us.tgstation13.org" "s3.tgstation13.org"];
  };

  services.logrotate.enable = false;

  services.openssh = {
    hostKeys = [
      {
        path = "/persist/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
    autoSnapshot.enable = false;
  };

  services.mysql = {
    dataDir = "/persist/mariadb";
  };

  age.secrets.tgs = {
    file = ./secrets/tgs.age;
    owner = "${config.services.tgstation-server.username}";
    group = "${config.services.tgstation-server.groupname}";
  };
  services.tgstation-server = {
    environmentFile = config.age.secrets.tgs.path;
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        domain = "tgsatan.tg.lan";
      };
    };
  };

  # TODO: Move this to it's own module, either in modules/ or a host based one
  age.secrets.restic-env.file = ./secrets/restic-env.age;
  age.secrets.restic-key.file = ./secrets/restic-key.age;
  services.restic = {
    backups.persist = {
      environmentFile = config.age.secrets.restic-env.path;
      passwordFile = config.age.secrets.restic-key.path;
      repository = "s3:s3.us-east-005.backblazeb2.com/tgstation-backups";
      extraBackupArgs = ["-v"];
      paths = ["/persist" "/root/tgsatan_maria.sql"];
      exclude = [
        "/persist/garage/data"
      ];
      backupPrepareCommand = ''
        ${pkgs.mariadb}/bin/mysqldump --all-databases > /root/tgsatan_maria.sql
      '';
      backupCleanupCommand = ''
        rm /root/tgsatan_maria.sql
      '';
    };
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      nvidia-stats = {
        hostname = "nvidia-stats";
        image = "nvcr.io/nvidia/k8s/dcgm-exporter:3.3.8-3.6.0-ubuntu22.04";
        ports = ["127.0.0.1:9400:9400"];
        extraOptions = [
          "--cap-add"
          "SYS_ADMIN"
          "--device"
          "nvidia.com/gpu=all"
        ];
      };
    };
  };
}
