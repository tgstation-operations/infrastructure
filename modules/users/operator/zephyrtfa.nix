{
  pkgs,
  config,
  ...
}: {
  users.users.zephyrtfa = {
    isNormalUser = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPvRq0FC5TOB9c+XRJdx20JUSga76R3Ohni3FH7trzgE derg@derg-nix"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBWWfCrgbiXe608weuYqyakrXXeLQQZSLatp1qVDjdiX derg@framework"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICzChQLIu0ccsRpsxyQPoQh65D9iBw2wyWvsQNuFYP7i matth@MSI"
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
