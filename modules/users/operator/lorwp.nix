{
  pkgs,
  config,
  ...
}: {
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
  };

  home-manager.users.lorwp = {
#    programs.helix = {
#      defaultEditor = true;
#      enable = true;
#      extraPackages = [
#        pkgs.nixd
#        pkgs.git
#        pkgs.alejandra
#      ];
#      settings = {
#        theme = "catppuccin_macchiato";
#      };
#    };
    home.packages = with pkgs; [
      bandwhich
      btop
      termscp
      lazygit
      jq
    ];
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      initContent = ''
        eval $(${pkgs.starship}/bin/starship init zsh)
        eval $(${pkgs.nix-your-shell}/bin/nix-your-shell zsh)
      '';
    };
    programs.fish = {
      enable = true;
      shellInit = ''
        if status is-interactive
          set fish_greeting
          eval $(${pkgs.starship}/bin/starship init fish)
        end
      '';
    };
    home.stateVersion = config.system.stateVersion;
  };
}
