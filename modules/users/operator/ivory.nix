{pkgs, ...}: {
  # also known as strandsofivy
  users.users.ivory = {
    isNormalUser = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGHe24kPrUqEMah1kKJikyiBcPpBraND5nAkyTb0Rdat ivory@sharksrock"
    ];

    extraGroups = [
      "wheel"
    ];

    shell = pkgs.zsh;

    packages = with pkgs; [
      bat
      tshark
      btop
      lazygit
    ];
  };
}
