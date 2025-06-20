let
  system = import ../../../../../../modules/ssh_keys_systems.nix;
in
  with system; {
    "tgsatan.ca.crt".publicKeys = [tgsatan];
    "tgsatan.node.crt".publicKeys = [tgsatan];
    "tgsatan.node.key".publicKeys = [tgsatan];
    "client.cockroachdb.crt".publicKeys = [tgsatan];
    "client.cockroachdb.key".publicKeys = [tgsatan];
  }
