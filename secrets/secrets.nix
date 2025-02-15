let
  users = import ../../../modules/ssh_keys.nix;

  # Systems
  tgsatan = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAgFJAiZ7gf+LoAyNVqMBXTNcGETJJZreVzMOGbOd2C5";
  systems = [tgsatan];
in {
  # Intentionally blank, we have no shared secrets yet
}
