{...}: {
  imports = [
    ../base.nix
    ../disko-hetzner-arm-uefi.nix
  ];
  ## BRATWURST - Nuremberg, Germany. Owned by Mothblocks
  networking.hostName = "bratwurst";
  system.stateVersion = "24.11";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "xen_blkfront"
  ];
  boot.initrd.kernelModules = ["nvme"];
  documentation.man.generateCaches = false; # This makes the binfmt build unbearably slow, so we disable it
}
