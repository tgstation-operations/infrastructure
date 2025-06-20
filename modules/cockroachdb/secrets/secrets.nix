let
  users = import ../../../../../../modules/ssh_keys_by_group.nix {group = "db-operator";};
in {
  "ca.key".publicKeys = users;
  "client.cockroachdb.crt".publicKeys = users;
  "client.cockroachdb.key".publicKeys = users;
}
