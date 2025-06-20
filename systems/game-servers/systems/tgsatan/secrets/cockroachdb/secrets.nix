let
  users = import ../../../../../../modules/ssh_keys_by_group.nix {group = "db-operator";};
  system = import ../../../../../../modules/ssh_keys_systems.nix;
in
  with system; {
    "tgsatan.ca.crt".publicKeys = [tgsatan] ++ users;
    "tgsatan.node.crt".publicKeys = [tgsatan] ++ users;
    "tgsatan.node.key".publicKeys = [tgsatan] ++ users;
    "client.cockroachdb.crt".publicKeys = [tgsatan] ++ users;
    "client.cockroachdb.key".publicKeys = [tgsatan] ++ users;
  }
