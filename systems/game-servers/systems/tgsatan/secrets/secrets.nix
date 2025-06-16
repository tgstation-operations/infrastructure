let
  users = import ../../../../../modules/ssh_keys_by_group.nix;
  tgsatan = (import ../../../../../modules/ssh_keys_system.nix).tgsatan;
  final = users ++ [tgsatan];
in {
  ## Restic
  "restic-env.age".publicKeys = final;
  "restic-key.age".publicKeys = final;
  # TGS
  "tgs.age".publicKeys = final;
  # Cloudflare
  "cloudflare_api.age".publicKeys = final;
  # Cloudflared
  "cloudflared.age".publicKeys = final;
  "cloudflared-pem.age".publicKeys = final;
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
}
