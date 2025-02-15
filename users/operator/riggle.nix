{
  pkgs,
  config,
  ...
}: {
  users.users.riggle = {
    isNormalUser = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDtHz4KGrjtIim0NzdYDu9T3Olcw9Ks5G+aDDHBEurkl riggle@Saiph"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMiO7rXqxAQKSBq46QVL5fD60FqhSA3Sa/schrDsQcv1 riggle@mintaka"
    ];

    extraGroups = [
      "wheel"
    ];

    shell = pkgs.zsh;
  };

  home-manager.users.riggle = {
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

    home.stateVersion = config.system.stateVersion;

    home.packages = with pkgs; [
      bat
      dogdns
      jq
      tshark
      zoxide
    ];
  };
}
