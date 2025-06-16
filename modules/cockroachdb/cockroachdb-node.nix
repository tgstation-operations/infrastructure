{
  cluster-nodes,
  ca-crt,
  node-crt,
  node-key,
}: {
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    26257 # SQL
    26258 # Admin Interface
  ];

  age.secrets.cockroachdb-tgstation-ca-crt = {
    file = ca-crt;
    owner = config.users.users.cockroachdb.name;
    group = config.users.groups.db-operator.name;
  };
  age.secrets.cockroachdb-tgstation-node-crt = {
    file = node-crt;
    owner = config.users.users.cockroachdb.name;
    group = config.users.groups.db-operator.name;
  };
  age.secrets.cockcockroachdb-tgstation-node-key = {
    file = node-key;
    owner = config.users.users.cockroachdb.name;
    group = config.users.groups.db-operator.name;
  };

  users.users.cockroachdb = {
    isSystemUser = true;
    shell = "${pkgs.nologin}/bin/nologin";
    group = "db-operator";
  };
  users.groups.db-operator.name = "db-operator";

  services.cockroachdb = {
    enable = true;
    http.port = 26258; # not using 8080 on purpose.
    listen.port = 26257; # this is the default, but you never know.
    join = cluster-nodes;
    user = "cockroachdb";
    group = "db-operator";
    certsDir = "/var/lib/cockroachdb/cert-store";
  };
  systemd.services.cockroachdb.serviceConfig.ExecStartPre = pkgs.writeShellScript "setup-certs-dir" ''
    mkdir -p /var/lib/cockroachdb/cert-store
    pushd /var/lib/cockroachdb/cert-store
    rm -f ca.crt node.crt node.key
    ln -s ${age.secrets.cockroachdb-tgstation-ca-crt.path} ca.crt
    ln -s ${age.secrets.cockroachdb-tgstation-node-crt.path} node.crt
    ln -s ${age.secrets.cockroachdb-tgstation-node-key.path} node.key
    popd
  '';
}
