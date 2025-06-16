let
  users = import ../../ssh_keys_by_group.nix {group = "db-operator";};
  systems = import ../../ssh_keys_systems.nix;
in {
  # todo: primary node with CA private for dynamic node issuance.
  "ca.key".publicKeys = users;

  # tgsatan
  "tgsatan.ca.crt".publicKeys = users ++ [systems.tgsatan];
  "tgsatan.node.crt".publicKeys = users ++ [systems.tgsatan];
  "tgsatan.node.key".publicKeys = users ++ [systems.tgsatan];
}
