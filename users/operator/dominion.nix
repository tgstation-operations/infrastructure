{
  pkgs,
  config,
  ...
}: {
  users.users.dominion = {
    isNormalUser = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJNL86w85bS/+5aDj8fe4gZ2obLiiRn+1lXhWA2tX7Jt eddsa-key-20241023"
    ];

    extraGroups = [
      "wheel"
    ];
  };

  home-manager.users.dominion = {
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
