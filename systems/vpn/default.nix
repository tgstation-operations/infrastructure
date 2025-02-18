{modulesPath, ...}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../../modules/openssh.nix
    ../../modules/tailscale.nix
    ../../modules/fail2ban.nix
    ../../modules/systemd-exporter.nix
    ./modules/headscale
  ];

  networking.hostName = "vpn";
  system.stateVersion = "24.11";
  services.tailscale = {
    openFirewall = true;
  };

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/3B3A-7736";
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
