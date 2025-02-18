{
  pkgs,
  config,
  ...
}: {
  users.users.scriptis = {
    isNormalUser = true;

    initialHashedPassword = "$y$j9T$sO2rV8ARIx2AOr6Z5DlKj.$s/18HTYZ.5v6xxkhTd0mWs2MHdUCLzoaWf.L0BIx4v0";

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILPyASt6VXR03toSHdcBG05m46EhbpcJjqL0GZTr04hC dt@prospekt"
    ];

    extraGroups = [
      "wheel"
      "podman"
    ];

    shell = pkgs.fish;
  };

  home-manager.users.scriptis = {
    programs.fish = {
      enable = true;

      shellInit = ''
        if status is-interactive
          set fish_greeting
          eval $(${pkgs.starship}/bin/starship init fish)
        end


        function nix-shell --description "Start an interactive shell based on a Nix expression"
          ${pkgs.nix-your-shell}/bin/nix-your-shell fish nix-shell -- $argv
        end

        function nix --description "Reproducible and declarative configuration management"
          ${pkgs.nix-your-shell}/bin/nix-your-shell fish nix -- $argv
        end
      '';
    };

    programs.git = {
      enable = true;
      lfs.enable = true;

      userName = "scriptis";
      userEmail = "me@scriptis.net";
    };

    home.stateVersion = config.system.stateVersion;
  };
}
