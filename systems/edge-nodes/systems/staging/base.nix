{
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../../../../modules/fail2ban.nix
    ../../../../modules/openssh.nix
    ../../../../modules/colmena_ci_staging.nix
    ./modules/caddy.nix
    ./modules/tailscale.nix
    ../../../../modules/netbird.nix
  ];

  tgstation.haproxy.relay-for = ["wiggle"];

  # A relay can be the exit route game servers egress through; which peers use
  # it is NetBird's to decide.
  networking.firewall.extraForwardRules = ''
    iifname "wt0" oifname != "wt0" accept
  '';

  services.tailscale.useRoutingFeatures = lib.mkForce "server";
  age.secrets.netbird-setup-key.file = ../../../../secrets/netbird-setup-key-staging.age;

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
}
