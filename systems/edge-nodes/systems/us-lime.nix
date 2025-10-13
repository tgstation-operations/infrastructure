{...}: {
  imports = [
    ../../../modules/maria.nix
    ../../../modules/restic.nix
    ../base.nix
    ../disko-ovh.nix
    ../modules/caddy.nix
    ../modules/server-info-fetcher.nix
  ];
  ## LIME - Vint Hill, VA. Owned by orangesnz
  networking.hostName = "lime";
  system.stateVersion = "24.11";
  boot.loader.grub = {
    enable = true;
  };
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "xen_blkfront"
    "vmw_pvscsi"
  ];
  boot.initrd.kernelModules = ["nvme"];
  services.mysql = {
    settings = {
      mariadb = {
        log_bin = "forum_master_bin";
        server_id = 1;
        log-basename = "forum_master_log";
        binlog-format = "mixed";
      };
    };
  };
}
