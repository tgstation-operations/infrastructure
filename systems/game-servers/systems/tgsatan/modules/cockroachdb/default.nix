{
  config,
  pkgs,
  ...
}:
import ../../../../../../modules/cockroachdb/cockroachdb-node.nix {
  inherit config pkgs;
  cluster-nodes = [
    "blockmoths.tg.lan"
    "tgsatan.tg.lan"
    "tg-db-cluster-node-neptune"
    "tg-db-cluster-node-solar"
  ];
  node-name = "tgsatan";
  node-crt = ./node.crt;
  node-key = ./secrets/node.key;
  db-user = "cockroachdb";
  db-user-crt = ./client.cockroachdb.crt;
  db-user-key = ./secrets/client.cockroachdb.key;
  root-key = ./secrets/client.root.key;
}
