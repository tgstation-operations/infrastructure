{
  config,
  pkgs,
  ...
}: {
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    3306
    4444
    4567
    4568
  ];
  networking.firewall.interfaces."tailscale0".allowedUDPPorts = [
    4567
  ];
  services.mysql = {
    enable = true;
    path = with pkgs; [
      bash
      gawk
      gnutar
      gzip
      inetutils
      iproute2
      netcat
      procps
      pv
      rsync
      socat
      stunnel
      which
    ];
    package = pkgs.mariadb;
    settings = {
      mariadb = {
        thread_handling = "pool-of-threads"; # TP size is num of cpus, 32 on satan
        max_connections = 302;
      };
      galera = {
        wsrep_provider = "${pkgs.mariadb-galera}/lib/galera/libgalera_smm.so";
        wsrep_on = "ON";
        wsrep_cluster_name = "/tg/ Cluster";
        wsrep_cluster_address = "gcomm://tgsatan.tg.lan,tg-db-cluster-node-neptune.tg.lan,tg-db-cluster-node-solar.tg.lan,blockmoths.tg.lan";
        binlog_format = "row";
        default_storage_engine = "InnoDB";
        innodb_autoinc_lock_mode = 2;
        innodb_doublewrite = 1;
        wsrep_slave_threads = 4;
        bind-address = "0.0.0.0";
      };
    };
  };
}
