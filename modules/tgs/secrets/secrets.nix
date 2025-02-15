let
  users = import ../../ssh_keys.nix;

  # Systems
  tgsatan = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAgFJAiZ7gf+LoAyNVqMBXTNcGETJJZreVzMOGbOd2C5";
  wiggle = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILz3vKC6Xr5fmXXU8BsY5oityIM60NmIaCyPTPUuZ35+";
  blockmoths = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHhSMBihD1sohp9h6tKYUd/BuyAsl0zOh/Uv86Gk/E/z";
  systems = [
    tgsatan
    wiggle
    blockmoths
  ];
in {
  "rsc-cdn.age".publicKeys = users ++ systems;
  # /tg/station13 main server secrets
  "tg13-dbconfig.age".publicKeys = users ++ systems;
  "tg13-comms.age".publicKeys = users ++ systems;
  "tg13-tts_secrets.age".publicKeys = users ++ systems;
  "tg13-extra_config-rclone.age".publicKeys = users ++ systems;
  # TGMC Secrets
  "tgmc-dbconfig.age".publicKeys = users ++ systems;
  "tgmc-tts_secrets.age".publicKeys = users ++ systems;
  "tgmc-extra_config-rclone.age".publicKeys = users ++ systems;
}
