{
  tunnel-id,
  age-file,
  config,
  pkgs,
  ...
}: {
  services.cloudflared = {
    enable = true;
    tunnels = {
      "${tunnel-id}" = {
        credentialsFile = config.age.secrets.cloudflared.path;
        default = "http_status:503";
      };
    };
  };
  age.secrets.cloudflared.file = age-file;
}
