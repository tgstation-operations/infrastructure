{
  pkgs,
  inputs,
}: let
  hostId = "8f33c04a";
in
  inputs.disko.lib.testLib.makeDiskoTest {
    inherit pkgs;
    name = "rollback-root";
    # The helper formats twice to check idempotency, and the host's hook fails
    # the second time because the snapshot already exists.
    disko-config = pkgs.lib.recursiveUpdate (import ../../systems/game-servers/systems/tgsatan/disko.nix) {
      disko.devices.zpool.zroot.datasets.root.postCreateHook = "zfs list -H -o name zroot/root@blank || zfs snapshot zroot/root@blank";
    };
    extraInstallerConfig.networking.hostId = hostId;
    extraSystemConfig = {
      imports = [../../systems/game-servers/modules/rollback-root.nix];
      networking.hostId = hostId;
      boot.supportedFilesystems = ["zfs"];
      boot.zfs.package = pkgs.zfs;
      fileSystems."/persist".neededForBoot = true;
    };
    extraTestScript = ''
      machine.succeed("touch /root-canary /persist/persist-canary")
      machine.shutdown()

      machine.start()
      machine.wait_for_unit("local-fs.target")
      machine.fail("test -e /root-canary")
      machine.succeed("test -e /persist/persist-canary")
      machine.succeed("journalctl -q -b UNIT=rollback-root.service JOB_TYPE=start JOB_RESULT=done | grep .")
      machine.fail("journalctl -q -b -u rollback-root.service | grep -F 'rollback failed'")
    '';
  }
