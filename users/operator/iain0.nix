{
  pkgs,
  config,
  ...
}: {
  users.users.iain0 = {
    isNormalUser = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBCaat3EUVrqal/XlY2e4mgXFhX/Izp7H+C/i32feW4P"
    ];

    # extraGroups = [
    #   "wheel"
    # ];
    shell = pkgs.fish;
  };

  home-manager.users.iain0 = {
    programs.bash = {
      enable = true;
      initExtra = ''
        eval $(${pkgs.starship}/bin/starship init bash)
        eval $(${pkgs.nix-your-shell}/bin/nix-your-shell bash)
      '';
    };

    # Put personal packages here, listed are just examples
    # home.packages = with pkgs; [
    #   bandwhich
    #   btop
    #   termscp
    #   lazygit
    # ];
    home.stateVersion = config.system.stateVersion;
  };
}
