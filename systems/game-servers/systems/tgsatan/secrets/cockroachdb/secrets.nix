let
  users = import ../../../../../../modules/ssh_keys_by_group.nix {group = "db-operator";};
  system = (import ../../../../../../modules/ssh_keys_systems.nix).tgsatan;
  final = users ++ [system];
in {
  "tgsatan.ca.crt".publicKeys = final;
  "tgsatan.node.crt".publicKeys = final;
  "tgsatan.node.key".publicKeys = final;
}
