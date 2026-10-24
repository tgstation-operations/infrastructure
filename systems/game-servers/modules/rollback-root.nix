# Rolls / back to its blank snapshot on every boot, between the pool import and
# the root mount. Failures are logged rather than failing the unit: a missed
# rollback costs one boot with a stale /, while a failed initrd unit leaves a
# remote host at an emergency shell nobody can reach.
{config, ...}: {
  boot.initrd.systemd.enable = true;

  boot.initrd.systemd.services.rollback-root = {
    description = "Roll back zroot/root to its blank snapshot";
    wantedBy = ["initrd.target"];
    after = ["zfs-import-zroot.service"];
    before = ["sysroot.mount"];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      ${config.boot.zfs.package}/bin/zfs rollback -r zroot/root@blank \
        || echo "rollback-root: rollback failed; this boot keeps the previous /"
    '';
  };
}
