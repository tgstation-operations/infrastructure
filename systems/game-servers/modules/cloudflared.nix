{
  age-file,
  config,
  pkgs,
  lib,
  ...
}: {
  services.cloudflared = {
    enable = true;
    certificateFile = config.age.secrets.cloudflared-cert.path;
    tunnels = {
      primary-tunnel = {
        credentialsFile = config.age.secrets.cloudflared-tunnel.path;
        default = "http_status:404";
      };
    };
  };
  age.secrets = {
    cloudflared-cert.file = ../secrets/cloudflared-cert.age;
    cloudflared-tunnel.file = age-file;
  };

  system.activationScripts = builtins.mapAttrs (script-name: published-route: {
    # Register the tunnel with DNS
    # Need the cert in-place temporarily for this
    text = pkgs.lib.stringAfter ["users"] ''
      mkdir /root/.cloudflared
      cp ${config.age.secrets.cloudflared-cert.path} /root/.cloudflared/cert.pem
      ${config.services.cloudflared.package}/bin/cloudflared tunnel route dns ${config.networking.hostName} ${published-route}
      rm -rf /root/.cloudflared
    '';
  }) builtins.listToAttrs (map (published-route: { name = "cloudflared-publish-route-${published-route}"; value = published-route; }) (lib.attrNames config.services.cloudflared.tunnels.primary-tunnel.ingress));
}
