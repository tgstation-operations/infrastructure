{pkgs, ...}: {
  users.users.lorwp = {
    isNormalUser = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM/S+F/9McI71cXhdMbbiEJW8MPaTm2TtFpkk9+M3gAM lorwp@lpc"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPRbRKoUPF4uCTLBn4lWZ8SABTFOymZpd8Qat07fAttI lorwp@lairm2"
    ];

    extraGroups = [
      "wheel"
    ];
    shell = pkgs.fish;

    packages = with pkgs; [
      bandwhich
      btop
      termscp
      lazygit
      jq
    ];
  };
}
