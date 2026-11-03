{config, ...}: {
  age.secrets = {
    restic-b2-env.file = ../secrets/restic-b2-env.age;
    restic-b2-key.file = ../secrets/restic-b2-key.age;
  };

  services.restic = {
    backups.persist = {
      passwordFile = config.age.secrets.restic-b2-key.path;
      environmentFile = config.age.secrets.restic-b2-env.path;
      createWrapper = true;
      extraBackupArgs = [
        "-v"
        "-H ${config.networking.hostName}"
      ];
      # restic runs rclone with --b2-hard-delete by default. Without it a
      # deletion only hides the file, and the bucket's lifecycle rules decide
      # how long it is kept.
      extraOptions = [
        "rclone.args=\"serve restic --stdio\""
      ];
      rcloneConfig.type = "b2";
      repository = "rclone:b2:tg-backups-demo/restic";
      paths = [
        "/persist"
      ];
      inhibitsSleep = true;
      progressFps = 0.1;
      timerConfig = {
        OnCalendar = "12:00";
        Persistent = true;
        RandomizedDelaySec = "5m";
      };
    };
  };
}
