{pkgs, ...}: {
  systemd.services.tgtts-qwen3-cache-cleaner = {
    description = "Clean tgtts-qwen3 cache";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "tgtts-qwen3-cache-cleaner.sh" ''
        if [ -d /persist/flakes/tgtts-qwen3/cache/ ]; then
          ${pkgs.findutils}/bin/find /persist/flakes/tgtts-qwen3/cache/ -mindepth 1 -mtime +2 -delete
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
