{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1M";
              type = "EF02"; # Dummy bit for a MBR, since this is a BIOS
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = ["-f"]; # Override existing partition
                # Subvolumes must set a mountpoint in order to be mounted,
                # unless their parent is mounted
                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                  };
                  "/nix" = {
                    mountOptions = ["compress=zstd" "noatime"];
                    mountpoint = "/nix";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
