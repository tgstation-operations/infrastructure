{inputs, ...}: {
  imports = [
    inputs.server-info-fetcher.nixosModules.default
  ];

  services.tgstation-server-info-fetcher = {
    enable = true;
    groupname = "caddy";
  };
}
