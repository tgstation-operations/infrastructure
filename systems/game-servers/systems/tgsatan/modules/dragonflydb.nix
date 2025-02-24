{
  config,
  pkgs,
  ...
}: {
  services.dragonflydb = {
    enable = true;
  };
}
