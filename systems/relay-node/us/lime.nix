{...}: {
  imports = [
    ../base.nix
    ../disko-ovh.nix
    ../modules/caddy.nix
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
}
