let
  users = import ../../../../../../../modules/ssh_keys_by_group.nix {group = "db-operator";};
  system = import ../../../../../../../modules/ssh_keys_systems.nix;
in
  with system; {
    "node.key".publicKeys = [blockmoths] ++ users;
    "client.cockroachdb.key".publicKeys = [blockmoths] ++ users;
    "client.root.key".publicKeys = [blockmoths] ++ users;
  }
