{
  age-file,
  config,
  pkgs,
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
}
