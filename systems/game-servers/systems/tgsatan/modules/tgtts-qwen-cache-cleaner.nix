{pkgs, ...}: {
  systemd.services.tgtts-qwen3-cache-cleaner = {
    description = "Clean tgtts-qwen3 cache";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "tgtts-qwen3-cache-cleaner.sh" ''
        if [ -d /persist/flakes/tgtts-qwen3/cache/ ]; then
          # Split into two steps to avoid "Directory not empty" errors from find -delete
          ${pkgs.findutils}/bin/find /persist/flakes/tgtts-qwen3/cache/ -mindepth 1 -ctime +2 -type f -delete
          ${pkgs.findutils}/bin/find /persist/flakes/tgtts-qwen3/cache/ -mindepth 1 -ctime +2 -type d -empty -delete
        fi
      '';
    };
  };

  systemd.timers.tgtts-qwen3-cache-cleaner = {
    description = "Timer for cleaning tgtts-qwen3 cache";
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      Unit = "tgtts-qwen3-cache-cleaner.service";
    };
    wantedBy = ["timers.target"];
  };
}
