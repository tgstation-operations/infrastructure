rec {
  # game nodes
  #  live
  tgsatan = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAgFJAiZ7gf+LoAyNVqMBXTNcGETJJZreVzMOGbOd2C5";
  blockmoths = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHhSMBihD1sohp9h6tKYUd/BuyAsl0zOh/Uv86Gk/E/z";
  game-nodes-live = [tgsatan blockmoths];

  #  staging
  wiggle = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILz3vKC6Xr5fmXXU8BsY5oityIM60NmIaCyPTPUuZ35+";
  game-nodes-staging = [wiggle];

  game-nodes-all = game-nodes-live ++ game-nodes-staging;

  # edge nodes
  #  eu
  bratwurst = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKMx0wL0vtoi+cVBGPLgfIabUbDYkNvcrLjmUBeJAtXD";
  dachshund = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPgQrCA2zPFEqa1L6+owVERY2spikooX0pUqUDRb+aAD";
  frankfurt2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINmTbUbMgrpIlsrSp41w6iFGzEuv8jA1ZMFkwbs1Sxkw";
  frankfurt3 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBktuwWGIps3ivY+h3H05G91rXGOTp9WzZP6A2HJjnGa";
  edge-nodes-eu = [bratwurst dachshund frankfurt2 frankfurt3];

  #  us
  knipp = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKpM1arHuexcm4OB8dASh2yHNbZKyDXwXwCxosGUhe5A";
  atlanta = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINl7JFsHToBHrhBossayigV+LIR8QBEj03qzGDQoTxty";
  chicago = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINLoHyAzZYLqehsiIFc06bVbSMWPu9WNy3/pM4UpkaCQ";
  dallas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxPsWAhIwv7iaVd2uJCjC/BqZDgXkMEQ5ZfWHESVAyT";
  lime = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILDcqEOMKjP4rtTC0qyl/oZx9C6Zfal+AbTY6nk87OPy";
  lemon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEhC4fn5nBZOw3nnQlvrKjEl/x7ObtSwoB0bCGy5gVkp";
  edge-nodes-na = [knipp atlanta chicago dallas lime lemon];

  #  staging
  warsaw = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAendJQ8VvBhnLl5Us7Q/2X9o6LSy8Ec7nXhs1JvLF3k";

  edge-nodes-staging = [warsaw];

  edge-nodes-live = edge-nodes-eu ++ edge-nodes-na;

  edge-nodes-all = edge-nodes-live ++ edge-nodes-staging;

  all = game-nodes-all ++ edge-nodes-all;

  vpn = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICw8296nzfeSNP3hKBLbybQcbhUsc5+vR/x2D0aLAAe/";
}
