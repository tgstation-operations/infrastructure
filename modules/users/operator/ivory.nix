{
  pkgs,
  config,
  ...
}: {
  users.users.ivory = { # also known as _distrilul or distributivgesetz
    isNormalUser = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGHe24kPrUqEMah1kKJikyiBcPpBraND5nAkyTb0Rdat ivory@sharksrock"
    ];

    extraGroups = [
      "wheel"
    ];

    shell = pkgs.zsh;
  };

  home-manager.users.ivory = {
    programs.zsh.enable = true;
    programs.zsh.autosuggestion.enable = true;
    programs.zsh.autosuggestion.highlight = "fg=#999";
    programs.zsh.syntaxHighlighting.enable = true;

    programs.starship.enable = true;
    programs.zoxide.enable = true;

    programs.zsh.initExtra = ''
      eval $(${pkgs.nix-your-shell}/bin/nix-your-shell zsh)
      bindkey '^H' backward-kill-word
      bindkey '5~' kill-word
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word
    '';

    home.packages = with pkgs; [
      bat
      tshark
      btop
      lazygit
    ];

    home.stateVersion = config.system.stateVersion;
  };
}
