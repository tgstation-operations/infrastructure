{
  lib,
  pkgs,
  config,
  ...
}: let
  redbot-instance = id: {
    enable = true;
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    path = with pkgs; [wget git python311Packages.fuzzywuzzy];
    serviceConfig = {
      User = "redbot-user";
      ExecStart = pkgs.writeShellScript "redbot-runner.sh" ''
        source /persist/redbot/bin/activate
        ${pkgs.python311Packages.pip}/bin/pip install -U pip wheel Red-DiscordBot
        exec redbot --team-members-are-owners ${id}
      '';
      TemporaryFileSystem = [
        "/persist:ro"
      ];
      ProtectSystem = "strict";
      BindPaths = [
        "/persist/redbot"
      ];
      PrivateTmp = true;
    };
  };
in {
  config = {
    users.users.redbot-user = {
      group = "redbot-user";
      home = "/persist/redbot";
      isSystemUser = true;
    };
    users.groups.redbot-user = {};

    systemd.services.redbot-fridge = redbot-instance "fridge";
    systemd.services.redbot-tg = redbot-instance "tg";
  };
}
