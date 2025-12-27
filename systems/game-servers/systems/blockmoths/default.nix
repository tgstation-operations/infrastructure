{
  inputs,
  pkgs,
  config,
  lib,
  tg-globals,
  headscaleIPv4,
  ...
}: let
  hw = inputs.nixos-hardware.nixosModules;
  baseModules = [
    (import hw.common-cpu-amd)
    inputs.oidc-reverse-proxy.nixosModules.default
    inputs.tg-public-log-parser.nixosModules.default
    inputs.tgstation-server.nixosModules.default
  ];
  localModules = [
    ./disko.nix
    ./modules/caddy
    ./modules/haproxy
    ./modules/motd
    (import ../../modules/logs {
      inherit pkgs config tg-globals;
      instance-name = "terry";
      bind-port = "3337";
      internal-port = "13337";
      raw-port = "23337";
      raw-internal-port = "23338";
    })
    ../../../../modules/fail2ban.nix
    ../../../../modules/openssh.nix
    ../../../../modules/tailscale.nix
    ../../../../modules/restic.nix
    (import ../../modules/cloudflared.nix {
      inherit pkgs config lib;
      age-file = ./secrets/cloudflared.age;
    })
    (import ../../modules/garage {
      inherit pkgs config lib headscaleIPv4;
      enable-webui = false;
    })
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
