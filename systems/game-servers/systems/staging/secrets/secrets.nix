let
  users = import ../../../../../modules/ssh_keys_by_group.nix {};
  wiggle = (import ../../../../../modules/ssh_keys_systems.nix).wiggle;
  final = users ++ [wiggle];
in {
  # TGS
  "tgs.age".publicKeys = final;
  # Cloudflared tunnel credentials file
  # Run "cloudflared tunnel create --cred-file cred.json wiggle" after logging in to generate in cred.json
  # NAME MUST MATCH HOSTNAME
  "cloudflared.age".publicKeys = final;
  # Contains RAW_LOGS_CLIENT_SECRET for OIDC for raw-logs
  "caddy_env.age".publicKeys = final;
}
