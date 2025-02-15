{
  pkgs,
  config,
  ...
}: {
  users.users.iamgoofball = {
    isNormalUser = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILtOOXa0BRGNbWW9/Plcln8XtrfzETX1WOmBfaL6nKzz iamgo@DESKTOP-KHD5G13"
    ];
  };

  home-manager.users.iamgoofball = {
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
