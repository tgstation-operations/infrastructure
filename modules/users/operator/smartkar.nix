{pkgs, ...}: {
  users.users.smartkar = {
    isNormalUser = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICe6BNfU6fZaeVV+pCGXzZaYX6u/yWIgvPlTgTnznPKX smartkar@pancakemachine"
    ];

    extraGroups = [
      "wheel"
    ];

    shell = pkgs.zsh;

    packages = with pkgs; [
      lazygit
      fzf
      tldr
      zoxide
    ];
  };
}
