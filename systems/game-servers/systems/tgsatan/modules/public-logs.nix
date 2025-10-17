{
  pkgs,
  tg-globals,
  ...
}: let
  public-logs-module = import ../../../modules/public-logs.nix;

  location-sybil = "${tg-globals.tgs.instances-path}/sybil/Configuration/GameStaticFiles/data/logs";
  bind-port-sybil = "1338";

  location-manuel = "${tg-globals.tgs.instances-path}/manuel/Configuration/GameStaticFiles/data/logs";
  bind-port-manuel = "1448";

  location-tgmc = "${tg-globals.tgs.instances-path}/tgmc/Configuration/GameStaticFiles/data/logs";
  bind-port-tgmc = "5338";

  location-eventus = "${tg-globals.tgs.instances-path}/eventhallus/Configuration/GameStaticFiles/data/logs";
  bind-port-eventus = "7778";

  location-effigy = "${tg-globals.tgs.instances-path}/effigy/Configuration/GameStaticFiles/data/logs";
  bind-port-effigy = "7338";
in {
  services.cloudflared.tunnels.primary-tunnel.ingress = {
    "sybil-logs.tgstation13.org" = "http://localhost:${bind-port-sybil}";
    "manuel-logs.tgstation13.org" = "http://localhost:${bind-port-manuel}";
    "eventus-logs.tgstation13.org" = "http://localhost:${bind-port-eventus}";
    "effigy-logs.tgstation13.org" = "http://localhost:${bind-port-effigy}";

    # TODO: Enable, needs testing. Use tailnet for now
    #"tgmc-logs.tgstation13.org" = "http://localhost:${bind-port-tgmc}";
  };
  system.activationScripts.tgs-data-chmod = pkgs.lib.stringAfter ["users"] ''
    chmod g+rx ${tg-globals.tgs.root-path}
    chmod g+rx ${tg-globals.tgs.instances-path}
    declare -a arr=(
      "sybil"
      "manuel"
      "tgmc"
      "eventhallus"
      "effigy"
      )
    for d in "''${arr[@]}"; do
      chmod g+rx ${tg-globals.tgs.instances-path}/$d
      chmod g+rx ${tg-globals.tgs.instances-path}/$d/Configuration
      chmod g+rx ${tg-globals.tgs.instances-path}/$d/Configuration/GameStaticFiles
      chmod g+rx ${tg-globals.tgs.instances-path}/$d/Configuration/GameStaticFiles/data
      chmod -R g+rx ${tg-globals.tgs.instances-path}/$d/Configuration/GameStaticFiles/data/logs
    done
  '';
  imports = [
    (public-logs-module {
      inherit pkgs;
      logs-location = location-sybil;
      server-name = "sybil";
      serve-address = "0.0.0.0:${bind-port-sybil}";
    })
    (public-logs-module {
      inherit pkgs;
      logs-location = location-manuel;
      server-name = "manuel";
      serve-address = "0.0.0.0:${bind-port-manuel}";
    })
    (public-logs-module {
      inherit pkgs;
      logs-location = location-tgmc;
      server-name = "tgmc";
      serve-address = "0.0.0.0:${bind-port-tgmc}";
    })
    (public-logs-module {
      inherit pkgs;
      logs-location = location-eventus;
      server-name = "eventus";
      serve-address = "0.0.0.0:${bind-port-eventus}";
    })
    (public-logs-module {
      inherit pkgs;
      logs-location = location-effigy;
      server-name = "effigy";
      serve-address = "0.0.0.0:${bind-port-effigy}";
    })
  ];
}
