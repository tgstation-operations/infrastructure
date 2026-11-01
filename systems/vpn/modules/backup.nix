{
  config,
  lib,
  pkgs,
  ...
}: let
  user = "vpn-backup";
  dump = "vpn-backup-dump";
  archive = "/var/lib/vpn-backup/vpn.tar";
  lemonKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA9vax2Hwgk53ghatgj34fothWvZCliX5d7T3b1foYcg lemon restic-backups-vpn";
  fetch = pkgs.writeShellApplication {
    name = "vpn-backup-fetch";
    runtimeInputs = [config.systemd.package pkgs.coreutils];
    text = ''
      systemctl start ${dump}.service
      cat ${archive}
    '';
  };
in {
  # lemon backs vpn up, which has too little memory for the shared
  # repository's index. Its key can only start the dump and read the archive.
  users.users.${user} = {
    isSystemUser = true;
    group = user;
    useDefaultShell = true;
    openssh.authorizedKeys.keys = [''restrict,command="${lib.getExe fetch}" ${lemonKey}''];
  };
  users.groups.${user} = {};

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.systemd1.manage-units" &&
          action.lookup("unit") == "${dump}.service" &&
          action.lookup("verb") == "start" &&
          subject.user == "${user}") {
        return polkit.Result.YES;
      }
    });
  '';

  systemd.services.${dump} = {
    path = [pkgs.gnutar pkgs.sqlite pkgs.util-linux];
    serviceConfig = {
      Type = "oneshot";
      Group = user;
      UMask = "0027";
      StateDirectory = "vpn-backup";
      StateDirectoryMode = "0750";
      PrivateTmp = true;
    };
    script = ''
      stage=$(mktemp -d)
      cp -a --parents /etc /var/lib/headscale /var/lib/netbird-mgmt /var/lib/tailscale "$stage"

      # A copy of a live database can be torn, so each is replaced with a
      # backup made as its owner: as root, sqlite3 could leave the service a
      # WAL file it cannot open.
      copies=$(mktemp -d)
      chmod 1777 "$copies"
      for db in /var/lib/headscale/*.sqlite /var/lib/netbird-mgmt/data/*.db; do
        setpriv --reuid="$(stat -c %u "$db")" --regid="$(stat -c %g "$db")" --clear-groups \
          sqlite3 "$db" ".backup '$copies/db'"
        mv "$copies/db" "$stage$db"
        rm -f "$stage$db-wal" "$stage$db-shm" "$stage$db-journal"
      done

      tar -C "$stage" --sort=name -cf ${archive}.new .
      mv ${archive}.new ${archive}
    '';
  };
}
