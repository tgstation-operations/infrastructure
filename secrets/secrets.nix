let
  users = import ../modules/ssh_keys_by_group.nix {};
  systems = import ../modules/ssh_keys_systems.nix;
  final = users ++ systems.all;
  backup-hosts = with systems; [tgsatan blockmoths lemon];
in {
  # Go to the /tg/ cf account api tokens page https://dash.cloudflare.com/9e75f02500238531febdd3388a9d9544/api-tokens, Create Token at the top, Edit zone DNS template
  "cloudflare-api.age".publicKeys = final;
  "restic_key.age".publicKeys = final;
  # RCLONE_CONFIG_B2_ACCOUNT and RCLONE_CONFIG_B2_KEY of an application key restricted to the tg-backups-demo bucket
  "restic-b2-env.age".publicKeys = users ++ backup-hosts;
  "restic-b2-key.age".publicKeys = users ++ backup-hosts;
  # Reusable setup keys from the NetBird dashboard, each bound to the group of the hosts that read it
  "netbird-setup-key-backend.age".publicKeys = users ++ systems.game-nodes-live ++ [systems.vpn];
  "netbird-setup-key-relay.age".publicKeys = users ++ systems.edge-nodes-live;
  "netbird-setup-key-staging.age".publicKeys = users ++ systems.game-nodes-staging ++ systems.edge-nodes-staging;
}
