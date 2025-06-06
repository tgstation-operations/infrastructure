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
    settings = {
      mariadb = {
        thread_handling = "pool-of-threads"; # TP size is num of cpus, 32 on satan
        max_connections = 302;
      };
    };
  };
}
