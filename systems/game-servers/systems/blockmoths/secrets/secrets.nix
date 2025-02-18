let
  users = import ../../../../../modules/ssh_keys.nix;

  # Systems
  blockmoths = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHhSMBihD1sohp9h6tKYUd/BuyAsl0zOh/Uv86Gk/E/z";
  systems = [blockmoths];
in {
  # TGS
  "tgs.age".publicKeys = users ++ systems;

  # Restic
  "restic-env.age".publicKeys = users ++ systems;
  "restic-key.age".publicKeys = users ++ systems;
  # Cloudflare DNS-01
  "cloudflare_api.age".publicKeys = users ++ systems;
  # AWS Route 53 DNS-01
  "aws_credentials.age".publicKeys = users ++ systems;
}
