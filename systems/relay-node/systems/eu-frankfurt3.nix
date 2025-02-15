{...}: {
  imports = [
    ../base.nix
  ];
  ## FRANKFURT3 - Frankfurt, Germany. Owned by host
  networking.hostName = "frankfurt3";
  system.stateVersion = "24.11";
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
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
