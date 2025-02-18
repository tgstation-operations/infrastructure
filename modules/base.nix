{
  self,
  pkgs,
  lib,
  ...
}: {
  environment.variables."FLAKE" = "${self}";

  security.sudo.execWheelOnly = true;
  security.sudo.extraConfig = ''
    Defaults lecture = never
  '';

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://attic.tgstation13.org/tgstation-infrastructure"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "tgstation-infrastructure:tNpjd5GxK1xymRHsJdBLTpeDScA2mVPdKA/eIOLOE0I="
    ];
    trusted-users = ["@wheel"];
  };

  nix.channel.enable = false;
  programs.command-not-found.enable = false;
  nixpkgs.config.allowUnfree = true;

  boot.kernelPackages = pkgs.linuxPackages_6_12;
  environment.systemPackages = with pkgs; [
    alejandra
    btop
    colmena
    duf
    dust
    ethtool
    fastfetch
    fd
    htop
    inxi
    lsd
    neovim
    networkd-dispatcher
    nh
    nil
    nixfmt-rfc-style
    pciutils
    restic
    ripgrep
    shellcheck
    tmux
    usbutils
  ];

  environment.enableAllTerminfo = true; # Enables (stable) terminfo for a bunch of extra terminals that aren't in ncurses yet (ghostty, alacritty, kitty, etc)
  time.timeZone = "Etc/UTC";
  services.timesyncd.enable = true;

  networking.firewall.enable = true;

  security.apparmor.enable = true;

  i18n.defaultLocale = "en_US.UTF-8";

  zramSwap.enable = true;
  zramSwap.memoryPercent = 50;

  services.fwupd.enable = true;

  systemd.ctrlAltDelUnit = "do-nothing.target";

  systemd.targets."do-nothing" = {
    enable = true;
    description = "Do Nothing";
  };

  users.defaultUserShell = pkgs.bash;

  networking.networkmanager.enable = true;

  networking.nftables.enable = true;

  hardware.enableRedistributableFirmware = true;

  security.sudo.wheelNeedsPassword = false;

  nix = {
    gc = {
      automatic = true;
      dates = ["daily"];
    };
    optimise = {
      automatic = true;
      dates = ["daily"];
    };
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
  };

  programs.fish.enable = true;
  programs.zsh.enable = true;

  home-manager.backupFileExtension = ".hm-backup";
}
