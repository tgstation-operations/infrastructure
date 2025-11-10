{
  config,
  pkgs,
  lib,
  self,
  tg-globals,
  ...
}: let
  hw = self.inputs.nixos-hardware.nixosModules;
  baseModules = [
    (import hw.common-gpu-nvidia)
    (import hw.common-cpu-amd)
    self.inputs.oidc-reverse-proxy.nixosModules.default
    self.inputs.tg-public-log-parser.nixosModules.default
    self.inputs.tgstation-server.nixosModules.default
  ];
  localModules = [
    ../../../../modules/fail2ban.nix
    ../../../../modules/maria.nix
    ../../../../modules/postgres.nix
    ../../../../modules/openssh.nix
    ../../../../modules/tailscale.nix
    ../../../../modules/restic.nix
    ../../modules/garage.nix
    ../../modules/motd.nix
    ../../modules/muffin-button.nix
    ../../modules/docker.nix
    ../../modules/tgs
    (import ../../modules/cloudflared.nix {
      inherit pkgs config lib;
      age-file = ./secrets/cloudflared.age;
    })
    (import ../../modules/logs {
      inherit pkgs config tg-globals;
      instance-name = "sybil";
      bind-port = "1338";
      internal-port = "13338";
      raw-port = "23338";
      raw-internal-port = "23339";
    })
    (import ../../modules/logs {
      inherit pkgs config tg-globals;
      instance-name = "manuel";
      bind-port = "1448";
      internal-port = "11448";
      raw-port = "21448";
      raw-internal-port = "21449";
    })
    (import ../../modules/logs {
      inherit pkgs config tg-globals;
      instance-name = "eventhallus";
      bind-port = "7778";
      internal-port = "17778";
      raw-port = "27778";
      raw-internal-port = "27779";
    })
    (import ../../modules/logs {
      inherit pkgs config tg-globals;
      instance-name = "effigy";
      bind-port = "7338";
      internal-port = "17338";
      raw-port = "27338";
      raw-internal-port = "27339";
    })
    (import ../../modules/logs {
      inherit pkgs config tg-globals;
      instance-name = "tgmc";
      bind-port = "7238";
      internal-port = "17238";
      raw-port = "37338";
      raw-internal-port = "37339";
      enable-public-logs = false;
      oidc-settings = {
        OpenIDConnectSettings = {
          Authority = "https://auth.tgstation13.org/application/o/tgmc-raw-logs";
          ClientId = "mtumSnN4SUweJicI6r1mRXtd8bBqfYjM6K8KdVA4";
        };
        age-name = "tgmc-raw-logs-oidc-reverse-proxy";
        age-path = ./secrets/tgmc-raw-logs-oidc-reverse-proxy.age;
      };
    })
    ./modules/atticd.nix
    ./modules/grafana
    ./modules/monitoring
    ./modules/motd
    ./modules/nvidia.nix
    ./modules/redbot.nix
  ];
in {
  networking.hostName = "tgsatan";
  networking.hostId = "8f33c04a";
  system.stateVersion = "24.05";

  imports =
    baseModules
    ++ localModules
    ++ [
      ./disko.nix
      ./modules/haproxy
      ./modules/caddy
    ];

  hardware.nvidia-container-toolkit.enable = true;

  programs.nix-ld.enable = true;

  boot = {
    supportedFilesystems = ["zfs"];
    zfs.package = pkgs.zfs;
    loader.systemd-boot.enable = true;
  };

  programs.fuse.userAllowOther = true;

  environment.persistence."/persist/system" = {
    hideMounts = false;

    directories = [
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/lib/tailscale"
      "/etc/NetworkManager/system-connections"
      "/var/lib/acme"
      "/var/lib/postgresql"
    ];
  };

  boot.initrd.postResumeCommands = lib.mkAfter ''
    zfs rollback -r zroot/root@blank
  '';

  fileSystems."/persist" = {
    neededForBoot = true;
  };

  networking.hosts = {
    "127.0.0.1" = ["manuel.tgstation13.org" "sybil.tgstation13.org" "tgsatan.us.tgstation13.org" "tgs.tgsatan.us.tgstation13.org" "s3.tgsatan.us.tgstation13.org" "s3.tgstation13.org"];
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
  age.secrets.tgs = {
    file = ./secrets/tgs.age;
    owner = "${config.services.tgstation-server.username}";
    group = "${config.services.tgstation-server.groupname}";
  };
  services.tgstation-server = {
    environmentFile = config.age.secrets.tgs.path;
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        domain = "tgsatan.tg.lan";
      };
    };
  };

  services.postgresql = {
    enable = true;
    # If you change this, you will need to perform manual cleanup
    # of removed users
    ensureUsers = [
      {
        name = "root";
      }
      # {
      #   name = "tgstation";
      #   ensureDBOwnership = true;
      # }
      # {
      #   name = "tgmc";
      #   ensureDBOwnership = true;
      # }
      {
        name = "grafana";
        ensureDBOwnership = true;
      }
      {
        name = "atticd";
        ensureDBOwnership = true;
      }
    ];

    ensureDatabases = [
      # "tgstation";
      # "tgmc";
      "grafana"
      "atticd"
    ];
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      nvidia-stats = {
        hostname = "nvidia-stats";
        image = "nvcr.io/nvidia/k8s/dcgm-exporter:3.3.8-3.6.0-ubuntu22.04";
        ports = ["127.0.0.1:9400:9400"];
        extraOptions = [
          "--cap-add"
          "SYS_ADMIN"
          "--device"
          "nvidia.com/gpu=all"
        ];
      };
    };
  };
}
