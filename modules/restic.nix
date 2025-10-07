{ config, ... }:
{
  age.secrets.restic_key.file = ../secrets/restic_key.age;

  services.restic = {
    backups.persist = {
      passwordFile = config.age.secrets.restic_key.path;
      createWrapper = true;
      extraBackupArgs = [
        "-v"
        "-H ${config.networking.hostName}"
      ];
      extraOptions = [
        "rclone.args=\"serve restic --stdio --config /persist/backup_rclone_conf.conf\""
      ];
      repository = "rclone:gdrive:restic";
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
