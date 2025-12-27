{
  config,
  pkgs,
  ...
}: {
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    3306
  ];
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    dataDir = "/persist/mariadb";
    settings = {
      mariadb = {
        thread_handling = "pool-of-threads"; # TP size is num of cpus, 32 on satan
        max_connections = 302;
        innodb_flush_method = "fsync";
      };
    };
  };
}
