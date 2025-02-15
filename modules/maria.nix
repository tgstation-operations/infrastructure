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
  };
}
