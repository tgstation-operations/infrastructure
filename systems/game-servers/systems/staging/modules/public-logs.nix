{pkgs,  ...}: let
  public-logs-module = import ../../../modules/public-logs.nix;

  location-funnyname = "/persist/tgs-data/instances/funnyname/Configuration/GameStaticFiles/data/logs";
  bind-port-funnyname = "3337";
in {
  services.cloudflared.tunnels.primary-tunnel.ingress = {
    "funnyname.logs.tgstation13.org" = "http://localhost:${bind-port-funnyname}";
  };
  system.activationScripts.tgs-data-chmod = pkgs.lib.stringAfter ["users"] ''
    chmod g+rx /persist/tgs-data
    chmod g+rx /persist/tgs-data/instances
    declare -a arr=(
      "funnyname"
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
    (public-logs-module {
      inherit pkgs;
      logs-location = location-funnyname;
      server-name = "funnyname"; # Not funnyname because we SOMEHOW BROKE CLOUDFLARE WITH THAT LMFAO
      serve-address = "0.0.0.0:${bind-port-funnyname}";
    })
  ];
}
