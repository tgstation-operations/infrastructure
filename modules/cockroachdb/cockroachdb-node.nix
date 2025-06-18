{
  # needed imports
  config,
  pkgs,
  age,
  # Cluster configuration
  cluster-nodes,
  ca-crt,
  node-crt,
  node-key,
  node-name,
  port-sql ? 26257,
  port-admin ? 26258,
  db-user ? "cockroachdb",
  db-group ? "db-operator",
}: {
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    port-sql
    port-admin
  ];

  age.secrets."cockroachdb-${node-name}-ca-crt" = {
    file = ca-crt;
    mode = "0440";
    owner = config.users.users.${db-user}.name;
    group = config.users.groups.${db-group}.name;
  };
  age.secrets."cockroachdb-${node-name}-node-crt" = {
    file = node-crt;
    mode = "0440";
    owner = config.users.users.${db-user}.name;
    group = config.users.groups.${db-group}.name;
  };
  age.secrets."cockroachdb-${node-name}-node-key" = {
    file = node-key;
    mode = "0440";
    owner = config.users.users.${db-user}.name;
    group = config.users.groups.${db-group}.name;
  };

  users.users.${db-user} = {
    isSystemUser = true;
    shell = "${pkgs.shadow}/bin/nologin";
    extraGroups = [db-group];
  };

  services.cockroachdb = {
    enable = true;
    listen.port = port-sql;
    http.port = port-admin;
    join = builtins.concatStringsSep "," cluster-nodes;
    user = db-user;
    group = db-user;
    certsDir = "/var/lib/cockroachdb/cert-store";
  };
  systemd.services.cockroachdb.serviceConfig.ExecStartPre = pkgs.writeShellScript "setup-certs-dir" ''
    mkdir -p /var/lib/cockroachdb/cert-store
    pushd /var/lib/cockroachdb/cert-store
    rm -f ca.crt node.crt node.key
    ln -s ${age.secrets."cockroachdb-${node-name}-ca-crt".path} ca.crt
    ln -s ${age.secrets."cockroachdb-${node-name}-node-crt".path} node.crt
    ln -s ${age.secrets."cockroachdb-${node-name}-node-key".path} node.key
    popd
  '';
}
