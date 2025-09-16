{pkgs, ...}: let
  raw-logs-module = import ../../modules/game-logs/raw-logs.nix;

  location-sybil = "/persist/tgs-data/instances/sybil/Configuration/GameStaticFiles/data/logs";
  bind-sybil = "0.0.0.0:1338";

  location-manuel = "/persist/tgs-data/instances/manuel/Configuration/GameStaticFiles/data/logs";
  bind-manuel = "0.0.0.0:1448";

  location-tgmc = "/persist/tgs-data/instances/tgmc/Configuration/GameStaticFiles/data/logs";
  bind-tgmc = "0.0.0.0:5338";

  location-eventus = "/persist/tgs-data/instances/eventhallus/Configuration/GameStaticFiles/data/logs";
  bind-eventus = "0.0.0.0:7778";

  location-effigy = "/persist/tgs-data/instances/effigy/Configuration/GameStaticFiles/data/logs";
  bind-effigy = "0.0.0.0:7338";
in {
  system.activationScripts.tgs-data-chmod = pkgs.lib.stringAfter ["users"] ''
    chmod g+rx /persist/tgs-data
    chmod g+rx /persist/tgs-data/instances
    for d in [
      sybil
      manuel
      tgmc
      eventhallus
      effigy
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
      logs-location = location-sybil;
      server-name = "sybil";
      serve-address = bind-sybil;
    })
    (raw-logs-module {
      inherit pkgs;
      logs-location = location-manuel;
      server-name = "manuel";
      serve-address = bind-manuel;
    })
    (raw-logs-module {
      inherit pkgs;
      logs-location = location-tgmc;
      server-name = "tgmc";
      serve-address = bind-tgmc;
    })
    (raw-logs-module {
      inherit pkgs;
      logs-location = location-eventus;
      server-name = "eventus";
      serve-address = bind-eventus;
    })
    (raw-logs-module {
      inherit pkgs;
      logs-location = location-effigy;
      server-name = "effigy";
      serve-address = bind-effigy;
    })
  ];
}
