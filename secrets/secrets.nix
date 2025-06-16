let
  users = import ../../../modules/ssh_keys.nix;
  systems = import ../../../modules/ssh_keys_system.nix;
in {
  # Intentionally blank, we have no shared secrets yet
}
