{
  config,
  pkgs,
  lib,
  ...
}: {
  age.secrets.attic.file = ../secrets/attic.age;
  services.atticd = {
    enable = true;
    user = "atticd";
    group = "atticd";
    settings = {
      # <https://github.com/zhaofengli/attic/blob/main/server/src/config-template.toml>
      listen = "127.0.0.1:9228";
      api-endpoint = "https://attic.tgstation13.org/";
      allowed-hosts = [
        "attic.tgstation13.org"
      ];
      database.url = lib.mkForce "postgresql://${config.services.atticd.user}?host=/run/postgresql/";
      storage = {
        type = "s3";
        region = "garage";
        bucket = "attic";
        endpoint = "https://s3.tgstation13.org";
      };
      compression = {
        type = "zstd"; # Default
      };
      garbage-collection = {
        interval = "12 hours"; # Default
        default-retention-period = "6 months"; # Default, can be changed on a per cache basis
      };
    };
    environmentFile = config.age.secrets.attic.path;
  };
}
