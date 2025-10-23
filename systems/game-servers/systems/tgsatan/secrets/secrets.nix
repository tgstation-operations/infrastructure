let
  users = import ../../../../../modules/ssh_keys_by_group.nix {};
  tgsatan = (import ../../../../../modules/ssh_keys_systems.nix).tgsatan;
  final = users ++ [tgsatan];
in {
  ## Restic
  "restic-env.age".publicKeys = final;
  "restic-key.age".publicKeys = final;
  # TGS
  "tgs.age".publicKeys = final;
  # Cloudflared tunnel credentials file
  # Run "cloudflared tunnel create --cred-file cred.json tgsatan" after logging in to generate in cred.json
  # NAME MUST MATCH HOSTNAME
  "cloudflared-tunnel.age".publicKeys = final;
  # Tgstation website api key
  "tgstation-web-apikey.age".publicKeys = final;
  # AWS Route 53 DNS-01
  "aws_credentials.age".publicKeys = final;
  # Atticd
  "attic.age".publicKeys = final;
  # Grafana
  "grafana_db.age".publicKeys = final;
  "grafana_smtp.age".publicKeys = final;
  "grafana_admin.age".publicKeys = final;
  # Contains RAW_LOGS_CLIENT_SECRET for OIDC for raw-logs
  "caddy_env.age".publicKeys = final;
}
