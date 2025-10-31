{
  pkgs,
  config,
  ...
}: {
  users.users.zephyrtfa = {
    isNormalUser = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPvRq0FC5TOB9c+XRJdx20JUSga76R3Ohni3FH7trzgE derg@derg-nix"
    ];

    extraGroups = [
      "wheel"
      "db-operator"
    ];
  };

  home-manager.users.zephyrtfa = {
    programs.bash = {
      enable = true;
      enableCompletion = true;
      initExtra = ''
        eval $(${pkgs.starship}/bin/starship init bash)
      '';
    };

    home.stateVersion = config.system.stateVersion;
  };
}
