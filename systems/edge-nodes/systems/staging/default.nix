{
  self,
  ...
}: {
  imports = [
    ./base.nix
    ../../modules/bab
    ../../modules/server-info-fetcher.nix
    self.inputs.tgstation-phpbb.nixosModules.default
  ];
  ## WARSAW - Warsaw, Poland. Owned by Host. Staging.
  networking.hostName = "warsaw";
  system.stateVersion = "24.11";
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };
  services.tgstation-phpbb = {
    enable = true;
    groupname = "caddy";
    cache-path = "/persist/tgstation-phpbb/cache";
    avatars-path = "/persist/tgstation-phpbb/avatars";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/E997-16AB";
    fsType = "vfat";
  };
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "xen_blkfront"
    "vmw_pvscsi"
  ];
  boot.initrd.kernelModules = ["nvme"];
  fileSystems."/" = {
    device = "/dev/vda2";
    fsType = "ext4";
  };
}
