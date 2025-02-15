{
  pkgs,
  config,
  ...
}: {
  users.users.zephyrtfa = {
    isNormalUser = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOxlNiboPEkPbIo0UhWZt0TiMtV+ZgiQxGD8gtjZjORV derg@derg-local"
    ];

    extraGroups = [
      "wheel"
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
