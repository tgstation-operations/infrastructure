{
  pkgs,
  config,
  ...
}: {
  users.users.sothanforax = { # I am bad at coming up with usernames and I don't feel like bothering with my local one, as much as dmr needs his respects paid.
    isNormalUser = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHdsT+cVuNnaCX+IJtsJ/h++DhYaS+TvwVoeFkFiTHo8 mk@Manganese"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINMioHFvfZt/v3I3K02DENMvj+CQLOUDdlkIVwxbYBIr u0_a325@localhost"
    ];

    extraGroups = [
      "wheel"
    ];

    shell = pkgs.zsh;
  };

  home-manager.users.sothanforax = {
    programs.zsh.enable = true;
    programs.zsh.autosuggestion.enable = true;
    programs.zsh.autosuggestion.highlight = "fg=#999";
    programs.zsh.syntaxHighlighting.enable = true;

    programs.starship.enable = true;

    programs.zsh.initContent = ''
      eval $(${pkgs.nix-your-shell}/bin/nix-your-shell zsh)
      bindkey '^H' backward-kill-word
      bindkey '5~' kill-word
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word
    '';

    home.packages = with pkgs; [
      vim
      btop
      fzf
      tshark
    ];

    home.stateVersion = config.system.stateVersion;
  };
}
