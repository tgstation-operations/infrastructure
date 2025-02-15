{
  pkgs,
  config,
  ...
}: {
  users.users.mothblocks = {
    isNormalUser = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHCfzjJUHmqv56u0T8vXcSOjKPEKPlcI0ujgsr8KmSsR mothblocks"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDRnJC3JX9oCcvfFAUc5CQqc3PAexP7NZgr/ebemtwmJ5OxGRrSk9DuKm7C1v/CAjqw+tB+gzBGiuYFUIdIJ0Awawy91QNsqOEsDM67cDzyRLO93cLFuDgdDi/fb7fZO8lk+q8RDsbjGwL18LJsehy2eEEo+sE4QPaFbTDyGpj3uTkJG0xr/ScyD7F0bO5PQRB7lJVsPP5TUWRYW0LzhxnPfYvN0JzUJD+cxjgbn8KFYmfkE65xHbpH16MTX/mkSqmKDnbXzxDb6oHFhNrmL81/HHUHpCDbN1l2ETY+TzGER+oadBm1gQ3B72xo2tiA0JPZ1ZOTDv+x7PgdakSWEdwL root@DESKTOP-CR9ML5R"
    ];
  };

  home-manager.users.mothblocks = {
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
