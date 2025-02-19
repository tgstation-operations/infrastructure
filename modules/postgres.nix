{
  config,
  pkgs,
  lib,
  ...
}: {
  services.postgres = {
    enable = true;
    port = 5432;
    package = pkgs.postgresql_17; # I like to live dangerously
    enableJIT = true;
    checkConfig = true;
    settings = {
      dataDir = "/persist/postgres/data";
    };

    # If you change this, you will need to perform manual cleanup
    # of removed users
    ensureUsers = [
      {
        name = "root";
      }
      # {
      #   name = "tgstation";
      # }
      # {
      #   name = "tgmc";
      # }
      {
        name = "grafana";
      }
    ];

    ensureDatabases = [
      # {
      #   name = "tgstation";
      #   owner = "tgstation";
      # }
      # {
      #   name = "tgmc";
      #   owner = "tgmc";
      # }
      {
        name = "grafana";
        owner = "grafana";
      }
    ];

    # https://www.postgresql.org/docs/current/auth-pg-hba-conf.html
    # type  database  user  [address]  [mask]  auth-method  [auth-options]
    # mkForce so we override defaults
    authentication = lib.mkForce ''
      # host    tgstation tgstation 127.0.0.1/32    scram-sha-256
      # hostssl tgstation tgstation 100.64.0.11/32  scram-sha-256
      # host    tgmc      tgmc      127.0.0.1/32    scram-sha-256
      host    grafana   grafana   127.0.0.1/32    scram-sha-256

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
