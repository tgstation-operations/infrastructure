{
  config,
  self,
  ...
}:
{
  imports = [
    self.inputs.tgstation-pr-announcer.nixosModules.default
  ];
  age.secrets.tgstation-pr-announcer = {
    file = ../../secrets/tgstation-pr-announcer.age;
    owner = "${config.services.tgstation-pr-announcer.username}";
    group = "${config.services.tgstation-pr-announcer.groupname}";
  };
  services.tgstation-pr-announcer = {
    enable = true;
    production-appsettings = ./appsettings.Production.json;
    environmentFile = config.age.secrets.tgstation-pr-announcer.path;
  };
}
