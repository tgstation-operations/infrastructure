{
  config,
  pkgs,
  ...
}:
import ../../../../../../modules/cockroachdb/cockroachdb-node.nix {
  inherit config pkgs;
  cluster-nodes = ["tgsatan.tg.lan"];
  node-name = "tgsatan";
  node-crt = ./node.crt;
  node-key = ./secrets/node.key;
  db-user = "cockroachdb";
  db-user-crt = ./client.cockroachdb.crt;
  db-user-key = ./secrets/client.cockroachdb.key;
  root-key = ./secrets/client.root.key;
}
