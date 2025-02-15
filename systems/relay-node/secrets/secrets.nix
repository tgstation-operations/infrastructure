let
  users = import ../../../modules/ssh_keys.nix;

  # Systems
  dallas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxPsWAhIwv7iaVd2uJCjC/BqZDgXkMEQ5ZfWHESVAyT";
  chicago = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINLoHyAzZYLqehsiIFc06bVbSMWPu9WNy3/pM4UpkaCQ";
  atlanta = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINl7JFsHToBHrhBossayigV+LIR8QBEj03qzGDQoTxty";
  frankfurt2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINmTbUbMgrpIlsrSp41w6iFGzEuv8jA1ZMFkwbs1Sxkw";
  frankfurt3 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBktuwWGIps3ivY+h3H05G91rXGOTp9WzZP6A2HJjnGa";
  lime = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILDcqEOMKjP4rtTC0qyl/oZx9C6Zfal+AbTY6nk87OPy";
  systems = [dallas chicago atlanta frankfurt2 frankfurt3 lime];
in {
  "cloudflare_api.age".publicKeys = users ++ systems;
}
