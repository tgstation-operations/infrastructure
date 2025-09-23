let
  users = import ../../../../../modules/ssh_keys_by_group.nix {};
  blockmoths = (import ../../../../../modules/ssh_keys_systems.nix).blockmoths;
  final = users ++ [blockmoths];
in {
  # TGS
  "tgs.age".publicKeys = final;
  # Restic
  "restic-env.age".publicKeys = final;
  "restic-key.age".publicKeys = final;
  # Cloudflare DNS-01
  "cloudflare_api.age".publicKeys = final;
  # Cloudflared
  "cloudflared.age".publicKeys = final;
  # AWS Route 53 DNS-01
  "aws_credentials.age".publicKeys = final;
}
