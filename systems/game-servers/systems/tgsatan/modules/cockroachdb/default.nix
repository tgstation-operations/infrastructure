import ../../../../../modules/cockroachdb/cockroachdb-node.nix {
  inherit config pkgs;
  cluster-nodes = ["tgsatan.tg.lan"];
  node-name = "tgsatan";
  node-crt = ./node.crt;
  node-key = ./secrets/node.key;
  db-user-crt = ./client.cockroachdb.crt;
  db-user-key = ./secrets/client.cockroachdb.key;
}
