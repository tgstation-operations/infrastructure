let
  users = import ../../../modules/ssh_keys.nix;

  # Systems
  dallas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxPsWAhIwv7iaVd2uJCjC/BqZDgXkMEQ5ZfWHESVAyT";
  chicago = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINLoHyAzZYLqehsiIFc06bVbSMWPu9WNy3/pM4UpkaCQ";
  atlanta = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINl7JFsHToBHrhBossayigV+LIR8QBEj03qzGDQoTxty";
  frankfurt2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINmTbUbMgrpIlsrSp41w6iFGzEuv8jA1ZMFkwbs1Sxkw";
  frankfurt3 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBktuwWGIps3ivY+h3H05G91rXGOTp9WzZP6A2HJjnGa";
  lime = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILDcqEOMKjP4rtTC0qyl/oZx9C6Zfal+AbTY6nk87OPy";
  bratwurst = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKMx0wL0vtoi+cVBGPLgfIabUbDYkNvcrLjmUBeJAtXD";
  dachshund = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPgQrCA2zPFEqa1L6+owVERY2spikooX0pUqUDRb+aAD";
  knipp = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKpM1arHuexcm4OB8dASh2yHNbZKyDXwXwCxosGUhe5A";
  systems = [dallas chicago atlanta frankfurt2 frankfurt3 lime bratwurst dachshund knipp];

  frontend_systems = [lime];
in {
  "cloudflare_api.age".publicKeys = users ++ frontend_systems;
  # TGS PR Announcer
  # The same value is used in game-servers/secrets/tg13-comms.age
  # TODO: Move to a shared secret (somehow)
  "tgstation-pr-announcer.age".publicKeys = users ++ frontend_systems;
  "tailscaleAuthKey.age".publicKeys = users ++ systems;
  "phpbb_db.age".publicKeys = users ++ frontend_systems;
}
