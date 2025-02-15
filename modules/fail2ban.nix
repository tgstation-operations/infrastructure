{
  config,
  pkgs,
  ...
}: {
  services.fail2ban = {
    enable = true;
  };
}
