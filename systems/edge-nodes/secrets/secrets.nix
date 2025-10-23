let
  users = import ../../../modules/ssh_keys_by_group.nix {};
  systems = import ../../../modules/ssh_keys_systems.nix;
  lemon-final = users ++ [systems.lemon];
in {
  "tailscaleAuthKey.age".publicKeys = users ++ systems.edge-nodes-all;
  # TGS PR Announcer
  # The same value is used in game-servers/secrets/tg13-comms.age
  # TODO: Move to a shared secret (somehow)
  "tgstation-pr-announcer.age".publicKeys = lemon-final;
  "phpbb_db.age".publicKeys = lemon-final;
  "authentik.age".publicKeys = lemon-final;
}
