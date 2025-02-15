{
  lib,
  pkgs,
  inputs,
  modulesPath,
  config,
  ...
}: let
  hw = inputs.nixos-hardware.nixosModules;
  baseModules = [
    (import hw.common-cpu-intel)
    inputs.tgstation-server.nixosModules.default
  ];
  localModules = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../../../../modules/colmena_ci_staging.nix
    ../../../../modules/fail2ban.nix
    ../../../../modules/systemd-exporter.nix
    ../../../../modules/openssh.nix
    ../../../../modules/tailscale.nix
    ../../modules/grafana.nix
    ../../modules/maria.nix
    ../../modules/motd.nix
    ../../modules/muffin-button.nix
    ../../modules/tgs
    ./modules/haproxy
    ./modules/motd
    ./modules/caddy.nix
    ./modules/kanidm.nix
  ];
in {
  networking.hostName = "wiggle";
  system.stateVersion = "24.11";

  systemd.network.wait-online.enable = false;
  boot.initrd.systemd.network.wait-online.enable = false;

  boot.loader.grub.device = "/dev/sda";
  services.xserver.xkb.layout = "us";

  imports = baseModules ++ localModules;

  programs.nix-ld.enable = true;

  systemd.network = {
    enable = true;
    networks = {
      "10-en" = {
        matchConfig.name = "en*";
        networkConfig.DHCP = "yes";
      };
    };
  };

  networking.nameservers = [
    "9.9.9.9"
    "1.1.1.1"
  ];

  age.secrets.tgs = {
    file = ./secrets/tgs.age;
    owner = "${config.services.tgstation-server.username}";
    group = "${config.services.tgstation-server.groupname}";
  };
  services.tgstation-server = {
    environmentFile = config.age.secrets.tgs.path;
  };

  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "virtio_pci"
    "virtio_scsi"
    "sd_mod"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/NIXBOOT";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  swapDevices = [];

  services.kanidm = {
    serverSettings = {
      domain = "idm.staging.tgstation13.org"; # If changed, you MUST run `kanidmd domain rename` immediately after. changes will break shit
      origin = "https://idm.staging.tgstation13.org";
    };
  };
  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.ens18.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
