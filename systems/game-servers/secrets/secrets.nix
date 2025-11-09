let
  users = import ../../../modules/ssh_keys_by_group.nix {};
  systems = import ../../../modules/ssh_keys_systems.nix;
  final = users ++ systems.game-nodes-all;
in {
  # Obtained by running "cloudflared login" then copying from ~/.cloudflared/cert.pem
  # Currently tied to Dominion's account
  "cloudflared-cert.age".publicKeys = final;

  "garage.age".publicKeys = final;

  "rsc-cdn.age".publicKeys = final;
  # /tg/station13 main server secrets
  "tg13-dbconfig.age".publicKeys = final;
  # The comms key in here is also used in the PR announcer
  # If you change it here change it there as well
  "tg13-comms.age".publicKeys = final;
  "tg13-tts_secrets.age".publicKeys = final;
  "tg13-webhooks.age".publicKeys = final;
  "tg13-extra_config-rclone.age".publicKeys = final;
  # TGMC Secret
  "tgmc-dbconfig.age".publicKeys = final;
  "tgmc-tts_secrets.age".publicKeys = final;
  "tgmc-extra_config-rclone.age".publicKeys = final;
  # Effigy server secrets
  "effigy-dbconfig.age".publicKeys = final;
  "effigy-comms.age".publicKeys = final;
  #"effigy-tts_secrets.age".publicKeys = final;
  "effigy-extra_config-rclone.age".publicKeys = final;
  # Contains RAW_LOGS_CLIENT_SECRET for OIDC for raw-logs
  "caddy_env.age".publicKeys = final;

  # OIDC Secret for raw-logs client
  "raw-logs-oidc-reverse-proxy.age".publicKeys = final;
}
