{
  config,
  pkgs,
  ...
}: {
  services.cloudflared = {
    enable = true;
    package = pkgs.cloudflared;
    tunnels = {
      "aeb3081d-b780-42bc-b062-d358eae5ec56" = {
        credentialsFile = config.age.secrets.cloudflared.path;
        };
      };
    };
  age.secrets = {
    cloudflared = {
      file = ./secrets/cloudflared.age;
      mode = "440";
      owner = "root";
      group = config.services.cloudflared.group;
    };
  };
}
