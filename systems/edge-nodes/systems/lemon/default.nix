{
  lib,
  self,
  config,
  ...
}: {
  imports = [
    ../../base.nix
    ../../../../modules/maria.nix
    ../../../../modules/restic.nix
    ../../modules/tgstation-pr-announcer
    ../../modules/server-info-fetcher.nix
    ./modules/mediawiki
    ./modules/caddy.nix
    # ../modules/tgstation-pr-announcer/default.nix
    self.inputs.tgstation-phpbb.nixosModules.default
  ];
  networking.hostName = "lemon";
  services = {
    mysql = {
      settings = {
        mariadb = {
          log_bin = "lemon_db_bin";
          server_id = 3;
          log-basename = "lemon_db_log";
          binlog-format = "mixed";
        };
      };
    };
    tgstation-phpbb = {
      enable = true;
      groupname = "caddy";
      cache-path = "/persist/tgstation-phpbb/cache";
      avatars-path = "/persist/tgstation-phpbb/avatars";
    };
    authentik = {
      environmentFile = config.age.secrets.authentik.path;
    };
  };

  age.secrets.authentik = {
    file = ../../secrets/authentik.age;
    owner = "${config.systemd.services.authentik.serviceConfig.User}";
  };

  system.stateVersion = "24.11";
  nixpkgs.hostPlatform = "x86_64-linux";
  boot = {
    loader.grub = {
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
    initrd = {
      availableKernelModules = ["virtio_scsi"];
      kernelModules = [];
    };
    kernelModules = ["kvmg-intel"];
    extraModulePackages = [];
  };
  disko.devices = {
    disk.disk1 = {
      device = lib.mkDefault "/dev/sda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "boot";
            size = "2M";
            type = "EF02";
          };
          esp = {
            name = "ESP";
            size = "300M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "lvm_pv";
              vg = "pool";
            };
          };
        };
      };
    };
    lvm_vg = {
      pool = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "100%FREE";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [
                "defaults"
              ];
            };
          };
        };
      };
    };
  };
}
