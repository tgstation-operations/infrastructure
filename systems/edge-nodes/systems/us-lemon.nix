{...}: {
  imports = [
    ../../../modules/maria.nix
    ../base.nix
    ../modules/caddy.nix
    ../modules/tgstation-pr-announcer/default.nix
  ];
  networking.hostName = "lemon";
  services.mysql = {
    dataDir = "/persist/mariadb";
  };

  system.stateVersion = "24.11";
  nixpkgs.hostPlatform = "x86_64-linux";
  boot = {
    loaders.grub = {
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
