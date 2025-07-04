{
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../../modules/fail2ban.nix
    ../../modules/openssh.nix
    ../../modules/colmena_ci.nix
    ./modules/tailscale.nix
    ./modules/haproxy
  ];

  services.tailscale.useRoutingFeatures = lib.mkForce "server";

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    trusted-users = ["@wheel"];
  };

  environment.enableAllTerminfo = true; # Enables (stable) terminfo for a bunch of extra terminals that aren't in ncurses yet (ghostty, alacritty, kitty, etc)

  # Raise UDP send/recv buffer size since we rely _very_ heavily on QUIC/WireGuard
  boot.kernel.sysctl."net.core.wmem_max" = 7500000;
  boot.kernel.sysctl."net.core.rmem_max" = 7500000;
}
