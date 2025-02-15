{
  pkgs,
  config,
  ...
}: {
  users.users.ned = {
    isNormalUser = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDTof05ZVWZirEwujb2eI9BQB3TXRW3vFfFnMu8cs1TT"
    ];
    extraGroups = [
      "wheel"
    ];
    shell = pkgs.fish;
  };

  home-manager.users.ned = {
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
