{
  config,
  pkgs,
  lib,
  headscaleIPv4,
  ...
}: {
  networking.firewall.allowedTCPPorts = [
    3901 # RPC
  ];
  age.secrets.garage.file = ../secrets/garage.age;

  services.garage = {
    enable = true;
    package = pkgs.garage_1_x; # Has to be set explicitly, to account for major version updates
    environmentFile = config.age.secrets.garage.path;
    settings = {
      # <https://garagehq.deuxfleurs.fr/documentation/reference-manual/configuration/>
      data_dir = "/persist/garage/data"; # This can be specified with an array of attribute sets instead to use multiple directories, if desired
      replication_factor = 2;
      metadata_dir = "/persist/garage/meta";
      db_engine = "lmdb";
      block_size = "1M"; # Default
      compression_level = 9;
      rpc_bind_addr = "${headscaleIPv4}:3901";
      rpc_public_addr = "${headscaleIPv4}:3901";
      # rpc_secret is set by $GARAGE_RPC_SECRET
      s3_api = {
        s3_region = "garage";
        api_bind_addr = "127.0.0.1:3900";
        root_domain = ".s3.tgstation13.org";
      };
      s3_web = {
        s3_region = "garage";
        bind_addr = "127.0.0.1:3902";
        root_domain = ".s3-web.tgstation13.org";
      };
      # k2v_api = {
      #   api_bind_addr = "[::]:3904";
      # };
      admin = {
        api_bind_addr = "127.0.0.1:3903";
        # admin_token and metrics_token are set by $GARAGE_ADMIN_TOKEN and $GARAGE_METRICS_TOKEN respectively if desired
      };
    };
  };
  # All of this below disables dynamicuser and uses a specific user account for running garage
  # TODO: Make this use dynamicuser. I couldn't figure this out, so any work to use it instead per their security guidance is welcome - lorwp
  users.users.garage = {
    isSystemUser = true;
    group = "garage";
  };
  users.groups.garage = {};
  systemd.services.garage = {
    serviceConfig = {
      User = "garage";
      Group = "garage";
      DynamicUser = false;
    };
  };
}
