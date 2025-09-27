{pkgs, ...}: let
  raw-logs-module = import ../../../modules/raw-logs.nix;

  location-terry = "/persist/tgs-data/instances/terry/Configuration/GameStaticFiles/data/logs";
  bind-port-terry = "3337";
in {
  services.cloudflared.tunnels.primary-tunnel.ingress = {
    "terry-logs.tgstation13.org" = {
      service = "http://localhost:${bind-port-terry}";
    };
  };
  system.activationScripts.tgs-data-chmod = pkgs.lib.stringAfter ["users"] ''
    chmod g+rx /persist/tgs-data
    chmod g+rx /persist/tgs-data/instances
    declare -a arr=(
      "terry"
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
      logs-location = location-terry;
      server-name = "terry";
      serve-address = "0.0.0.0:${bind-port-terry}";
    })
  ];
}
