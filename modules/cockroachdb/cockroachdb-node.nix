{
  # needed imports
  config,
  pkgs,
  # Cluster configuration
  cluster-nodes,
  node-name,
  node-address,
  # Node certificate and private key
  node-crt,
  node-key,
  db-user,
  # DB user certificate and private key
  db-user-crt,
  db-user-key,
  # public CA certificate. should be identical for all nodes in the same cluster.
  ca-crt ? ./ca.crt,
  # root certificate used for initializing a new node.
  root-crt ? ./client.root.crt,
  # root private key, must be encrypted per system.
  root-key,
}: let
  age = config.age;
in {
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    26257
    8080
  ];

  age.secrets."cockroachdb-${node-name}-${db-user}-key" = {
    file = db-user-key;
    mode = "0400";
    owner = config.users.users.${db-user}.name;
  };
  age.secrets."cockroachdb-${node-name}-root-key" = {
    file = root-key;
    mode = "0400";
    owner = config.users.users.${db-user}.name;
  };
  age.secrets."cockroachdb-${node-name}-node-key" = {
    file = node-key;
    mode = "0400";
    owner = config.users.users.${db-user}.name;
  };

  users.users.${db-user} = {
    isSystemUser = true;
    shell = "${pkgs.shadow}/bin/nologin";
  };

  services.cockroachdb = {
    enable = true;
    listen.address = "0.0.0.0";
    http.address = "0.0.0.0";
    extraArgs = [
      "--advertise-addr"
      "${node-address}"
      "--sql-addr"
      "0.0.0.0:26258"
    ];
    join = builtins.concatStringsSep "," cluster-nodes;
    user = db-user;
    group = db-user;
    certsDir = "/var/lib/cockroachdb/cert-store";
  };
  systemd.services.cockroachdb.serviceConfig.ExecStartPre = pkgs.writeShellScript "setup-certs-dir" ''
    mkdir -p /var/lib/cockroachdb/cert-store
    pushd /var/lib/cockroachdb/cert-store
    rm -f *
    ln -s ${ca-crt} ca.crt
    ln -s ${node-crt} node.crt
    ln -s ${root-crt} client.root.crt
    ln -s ${db-user-crt} client.${config.users.users.${db-user}.name}.crt
    ln -s ${age.secrets."cockroachdb-${node-name}-${db-user}-key".path} client.${config.users.users.${db-user}.name}.key
    ln -s ${age.secrets."cockroachdb-${node-name}-root-key".path} client.root.key
    ln -s ${age.secrets."cockroachdb-${node-name}-node-key".path} node.key
    popd
  '';
}
