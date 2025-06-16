let
  users = import ../../../modules/ssh_keys.nix;
  systems = import ../../../modules/ssh_keys_system.nix;
in {
  "garage.age".publicKeys = users ++ systems.all-game-nodes;

  "rsc-cdn.age".publicKeys = users ++ systems.all-game-nodes;
  # /tg/station13 main server secrets
  "tg13-dbconfig.age".publicKeys = users ++ systems.all-game-nodes;
  # The comms key in here is also used in the PR announcer
  # If you change it here change it there as well
  "tg13-comms.age".publicKeys = users ++ systems.all-game-nodes;
  "tg13-tts_secrets.age".publicKeys = users ++ systems.all-game-nodes;
  "tg13-webhooks.age".publicKeys = users ++ systems.all-game-nodes;
  "tg13-extra_config-rclone.age".publicKeys = users ++ systems.all-game-nodes;
  # TGMC Secret
  "tgmc-dbconfig.age".publicKeys = users ++ systems.all-game-nodes;
  "tgmc-tts_secrets.age".publicKeys = users ++ systems.all-game-nodes;
  "tgmc-extra_config-rclone.age".publicKeys = users ++ systems.all-game-nodes;
}
