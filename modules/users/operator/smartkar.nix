{
  pkgs,
  config,
  ...
}: {
  users.users.smartkar = {
    isNormalUser = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICe6BNfU6fZaeVV+pCGXzZaYX6u/yWIgvPlTgTnznPKX smartkar@pancakemachine"
    ];

    extraGroups = [
      "wheel"
    ];

    shell = pkgs.zsh;
  };

  home-manager.users.smartkar = {
    programs.starship.enable = true;
    programs.zoxide.enable = true;
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      initContent = ''
        eval $(${pkgs.starship}/bin/starship init zsh)
        eval $(${pkgs.nix-your-shell}/bin/nix-your-shell zsh)
      '';
    };

    home.packages = with pkgs; [
      lazygit
      fzf
      tldr
      zoxide
    ];

    home.stateVersion = config.system.stateVersion;
  };
}
