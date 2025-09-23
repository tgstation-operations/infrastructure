{pkgs, ...}: let
  raw-logs-module = import ../../modules/game-logs/raw-logs.nix;

  location-funnyname = "/persist/tgs-data/instances/funnyname/Configuration/GameStaticFiles/data/logs";
  bind-funnyname = "0.0.0.0:3337";
in {
  system.activationScripts.tgs-data-chmod = pkgs.lib.stringAfter ["users"] ''
    chmod g+rx /persist/tgs-data
    chmod g+rx /persist/tgs-data/instances
    for d in [
      funnyname
    ]; do
      chmod g+rx /persist/tgs-data/instances/$d
      chmod g+rx /persist/tgs-data/instances/$d/Configuration
      chmod g+rx /persist/tgs-data/instances/$d/Configuration/GameStaticFiles
      chmod g+rx /persist/tgs-data/instances/$d/Configuration/GameStaticFiles/data
      chmod -R g+rx /persist/tgs-data/instances/$d/Configuration/GameStaticFiles/data/logs
    done
  '';
  imports = [
    (raw-logs-module {
      inherit pkgs;
      logs-location = location-funnyname;
      server-name = "funnyname";
      serve-address = bind-funnyname;
    })
  ];
}
