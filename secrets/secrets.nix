let
  users = import ../../../modules/ssh_keys_by_group.nix {};
  systems = import ../../../modules/ssh_keys_system.nix;
in {
  # Intentionally blank, we have no shared secrets yet
}
