{
  config,
  pkgs,
  ...
}: let
  vpnHostKey = (import ../../../../../modules/ssh_keys_systems.nix).vpn;
  knownHosts = pkgs.writeText "vpn-known-hosts" "vpn.tgstation13.org ${vpnHostKey}\n";
in {
  age.secrets.vpn-backup-ssh-key.file = ../../../secrets/vpn-backup-ssh-key.age;

  services.restic.backups.vpn = {
    inherit (config.services.restic.backups.persist) passwordFile environmentFile extraOptions rcloneConfig repository timerConfig;
    command = [
      "${pkgs.openssh}/bin/ssh"
      "-T"
      "-i"
      config.age.secrets.vpn-backup-ssh-key.path
      "-o"
      "BatchMode=yes"
      "-o"
      "UserKnownHostsFile=${knownHosts}"
      "vpn-backup@vpn.tgstation13.org"
    ];
    extraBackupArgs = [
      "-v"
      "-H vpn"
      "--stdin-filename vpn.tar"
    ];
  };
}
