let
  users = import ../../../modules/ssh_keys.nix;
  systems = import ../../../modules/ssh_keys_system.nix;
in {
  "cloudflare_api.age".publicKeys = users ++ systems.all-edge-nodes;
  "tailscaleAuthKey.age".publicKeys = users ++ systems.all-edge-nodes;
  # TGS PR Announcer
  # The same value is used in game-servers/secrets/tg13-comms.age
  # TODO: Move to a shared secret (somehow)
  "tgstation-pr-announcer.age".publicKeys = users ++ systems.lime;
  "phpbb_db.age".publicKeys = users ++ systems.lime;
}
