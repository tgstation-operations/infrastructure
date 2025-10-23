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
  # Cloudflared tunnel credentials file
  # Run "cloudflared tunnel create --cred-file cred.json blockmoths" after logging in to generate in cred.json
  # NAME MUST MATCH HOSTNAME
  "cloudflared.age".publicKeys = final;
  # AWS Route 53 DNS-01
  "aws_credentials.age".publicKeys = final;
  # Contains RAW_LOGS_CLIENT_SECRET for OIDC for raw-logs
  "caddy_env.age".publicKeys = final;
}
