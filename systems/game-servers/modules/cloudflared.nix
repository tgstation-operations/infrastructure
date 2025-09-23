{
  age-file,
  config,
  pkgs,
  ...
}: {
  services.cloudflared = {
    enable = true;
    tunnels = {
      "aeb3081d-b780-42bc-b062-d358eae5ec56" = {
        credentialsFile = config.age.secrets.cloudflared.path;
        default = "http_status:503";
      };
    };
  };
  age.secrets = {
    cloudflared = {
      file = age-file;
      mode = "440";
      owner = "root";
      group = config.services.cloudflared.group;
    };
  };
}
