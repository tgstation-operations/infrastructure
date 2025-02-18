{
  config,
  pkgs,
  ...
}: {
  users.motdFile = "/var/lib/rust-motd/motd";

  programs.rust-motd = {
    enable = true;

    # Already set by users.motdFile
    enableMotdInSSHD = false;

    settings = {
      service_status = {
        "Restic" = "restic-backups-persist";
      };

      filesystems.persist = "/persist";

      memory.swap_pos = "beside";
    };
  };
}
