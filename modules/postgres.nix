{
  config,
  pkgs,
  lib,
  ...
}: {
  services.postgresql = {
    enable = true;
    settings.port = 5432;
    package = pkgs.postgresql_17; # I like to live dangerously
    enableJIT = true;
    checkConfig = true;
    dataDir = "/persist/postgres/data";
    settings = {
      listen_addresses = lib.mkForce "localhost, ${config.networking.hostName}.tg.lan";
    };

    # https://www.postgresql.org/docs/current/auth-pg-hba-conf.html
    # type  database  user  [address]  [mask]  auth-method  [auth-options]
    # mkForce so we override defaults
    authentication = lib.mkForce ''
      # hostssl tgstation tgstation 100.64.0.11/32  scram-sha-256

      # Default values
      local all all              peer
      host  all all 127.0.0.1/32 scram-sha-256
      host  all all ::1/128      scram-sha-256
    '';
  };

  # Defaults to "*-*-* 01:15:00" (every day at 1:15 AM)
  services.postgresqlBackup = {
    enable = true;
    location = "/persist/postgres/backup";
    compressionLevel = 9;
  };
}
