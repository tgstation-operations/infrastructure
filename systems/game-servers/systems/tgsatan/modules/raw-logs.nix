{pkgs, ...}: let
  raw-logs-module = import ../../../modules/raw-logs.nix;

  location-sybil = "/persist/tgs-data/instances/sybil/Configuration/GameStaticFiles/data/logs";
  bind-port-sybil = "1338";

  location-manuel = "/persist/tgs-data/instances/manuel/Configuration/GameStaticFiles/data/logs";
  bind-port-manuel = "1448";

  location-tgmc = "/persist/tgs-data/instances/tgmc/Configuration/GameStaticFiles/data/logs";
  bind-port-tgmc = "5338";

  location-eventus = "/persist/tgs-data/instances/eventhallus/Configuration/GameStaticFiles/data/logs";
  bind-port-eventus = "7778";

  location-effigy = "/persist/tgs-data/instances/effigy/Configuration/GameStaticFiles/data/logs";
  bind-port-effigy = "7338";
in {
  services.cloudflared.tunnels.primary-tunnel.ingress = {
    "sybil-logs.tgstation13.org" = {
      service = "http://localhost:${bind-port-sybil}";
    };
    "manuel-logs.tgstation13.org" = {
      service = "http://localhost:${bind-port-manuel}";
    };
    "eventus-logs.tgstation13.org" = {
      service = "http://localhost:${bind-port-eventus}";
    };
    "effigy-logs.tgstation13.org" = {
      service = "http://localhost:${bind-port-effigy}";
    };
    # TODO: Enable, needs testing. Use tailnet
    #"tgmc-logs.tgstation13.org" = {
    #  service = "http://localhost:${bind-port-tgmc}";
    #};
  };
  system.activationScripts.tgs-data-chmod = pkgs.lib.stringAfter ["users"] ''
    chmod g+rx /persist/tgs-data
    chmod g+rx /persist/tgs-data/instances
    declare -a arr=(
      "sybil"
      "manuel"
      "tgmc"
      "eventhallus"
      "effigy"
      )
    for d in "''${arr[@]}"; do
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
      serve-address = "0.0.0.0:${bind-port-sybil}";
    })
    (raw-logs-module {
      inherit pkgs;
      logs-location = location-manuel;
      server-name = "manuel";
      serve-address = "0.0.0.0:${bind-port-manuel}";
    })
    (raw-logs-module {
      inherit pkgs;
      logs-location = location-tgmc;
      server-name = "tgmc";
      serve-address = "0.0.0.0:${bind-port-tgmc}";
    })
    (raw-logs-module {
      inherit pkgs;
      logs-location = location-eventus;
      server-name = "eventus";
      serve-address = "0.0.0.0:${bind-port-eventus}";
    })
    (raw-logs-module {
      inherit pkgs;
      logs-location = location-effigy;
      server-name = "effigy";
      serve-address = "0.0.0.0:${bind-port-effigy}";
    })
  ];
}
