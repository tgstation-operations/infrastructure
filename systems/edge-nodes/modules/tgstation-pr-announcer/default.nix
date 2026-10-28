{config, ...}: {
  imports = [
    ./service.nix
  ];
  age.secrets.tgstation-pr-announcer = {
    file = ../../secrets/tgstation-pr-announcer.age;
    owner = "${config.services.tgstation-pr-announcer.username}";
    group = "${config.services.tgstation-pr-announcer.groupname}";
  };
  # Its metrics, from appsettings.Production.json.
  networking.firewall.interfaces.wt0.allowedTCPPorts = [5004];

  services.tgstation-pr-announcer = {
    enable = true;
    production-appsettings = ./appsettings.Production.json;
    environmentFile = config.age.secrets.tgstation-pr-announcer.path;
  };
}
