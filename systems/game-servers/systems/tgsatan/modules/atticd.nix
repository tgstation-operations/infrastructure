{
  config,
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
      # atticd streams a NAR chunk by chunk, each one a request to garage, so at
      # the default 64 KiB a multi-GiB CUDA or ML NAR is tens of thousands of
      # requests. Larger chunks deduplicate less between versions of a package.
      # Only NARs pushed after a change are chunked at the new sizes.
      chunking = {
        nar-size-threshold = 64 * 1024; # Default
        min-size = 256 * 1024;
        avg-size = 1024 * 1024;
        max-size = 4 * 1024 * 1024;
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
