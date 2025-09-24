{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: let
  hw = inputs.nixos-hardware.nixosModules;
  baseModules = [
    (import hw.common-cpu-amd)
    inputs.tgstation-server.nixosModules.default
  ];
  localModules = [
    ./disko.nix
    ./raw-logs.nix
    ./modules/caddy
    ./modules/cockroachdb
    ./modules/haproxy
    ./modules/motd
    ../../../../modules/fail2ban.nix
    ../../../../modules/openssh.nix
    ../../../../modules/tailscale.nix
    (import ../../modules/cloudflared.nix {
      inherit pkgs config;
      tunnel-id = "4d8dc646-2f1e-4df4-9057-c4fd069fe789";
      age-file = ./secrets/cloudflared.age;
    })
    ../../modules/garage.nix
    ../../modules/motd.nix
    ../../modules/muffin-button.nix
    ../../modules/docker.nix
    ../../modules/tgs
  ];
in {
  networking.hostName = "blockmoths";
  networking.hostId = "1c7fe50a";
  system.stateVersion = "24.11";

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
  ];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

  services.xserver.xkb.layout = "us";

  imports = baseModules ++ localModules;

  programs.nix-ld.enable = true;

  age.secrets.tgs = {
    file = ./secrets/tgs.age;
    owner = "${config.services.tgstation-server.username}";
    group = "${config.services.tgstation-server.groupname}";
  };
  services.tgstation-server = {
    environmentFile = config.age.secrets.tgs.path;
  };

  environment.persistence."/persist/system" = {
    hideMounts = false;

    directories = [
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/lib/headscale"
      "/var/lib/tailscale"
      "/etc/NetworkManager/system-connections"
      "/var/lib/acme"
    ];
  };

  age.secrets.restic-env.file = ./secrets/restic-env.age;
  age.secrets.restic-key.file = ./secrets/restic-key.age;

  services.restic = {
    backups.persist = {
      environmentFile = config.age.secrets.restic-env.path;
      passwordFile = config.age.secrets.restic-key.path;
      repository = "s3:s3.us-east-005.backblazeb2.com/tgstation-backups";
      extraBackupArgs = ["-v"];
      paths = ["/persist"];
      exclude = [
        "/persist/garage"
      ];
    };
  };

  networking.hosts = {
    "127.0.0.1" = ["terry.tgstation13.org" "blockmoths.eu.tgstation13.org" "tgs.blockmoths.eu.tgstation13.org" "s3.blockmoths.eu.tgstation13.org" "s3.tgstation13.org"];
  };

  boot.initrd.postResumeCommands = lib.mkAfter ''
    zfs rollback -r zroot/root@blank
  '';

  fileSystems."/persist" = {
    neededForBoot = true;
  };

  boot = {
    supportedFilesystems = ["zfs"];
    zfs.package = pkgs.zfs;
    loader.systemd-boot.enable = true;
  };

  services.logrotate.enable = false;

  services.openssh = {
    hostKeys = [
      {
        path = "/persist/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
    autoSnapshot.enable = false;
  };
}
