let
  users = import ../../../modules/ssh_keys.nix;

  # Systems
  tgsatan = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAgFJAiZ7gf+LoAyNVqMBXTNcGETJJZreVzMOGbOd2C5";
  blockmoths = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHhSMBihD1sohp9h6tKYUd/BuyAsl0zOh/Uv86Gk/E/z";
  systems = [tgsatan blockmoths];
in {
  "garage.age".publicKeys = users ++ systems;
}
