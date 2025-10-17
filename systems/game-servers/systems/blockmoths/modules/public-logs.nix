{
  pkgs,
  tg-globals,
  ...
}: let
  public-logs-module = import ../../../modules/public-logs.nix;

  location-terry = "${tg-globals.tgs.instances-path}/terry/Configuration/GameStaticFiles/data/logs";
  bind-port-terry = "3337";
in {
  services.cloudflared.tunnels.primary-tunnel.ingress = {
    "terry-logs.tgstation13.org" = "http://localhost:${bind-port-terry}";
  };
  system.activationScripts.tgs-data-chmod = pkgs.lib.stringAfter ["users"] ''
    chmod g+rx ${tg-globals.tgs.root-path}
    chmod g+rx ${tg-globals.tgs.instances-path}
    declare -a arr=(
      "terry"
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
      logs-location = location-terry;
      server-name = "terry";
      serve-address = "0.0.0.0:${bind-port-terry}";
    })
  ];
}
