{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../../../../modules/tailscale.nix
  ];

  age.secrets.tailscaleAuthKey.file = ../secrets/tailscaleAuthKey.age;
  services.tailscale = {
    authKeyFile = config.age.secrets.tailscaleAuthKey.path;
    extraUpFlags = [
      "--advertise-exit-node" # make sure we can use any relay we want as an exit node
    ];
    extraSetFlags = [
      "--advertise-exit-node"
    ];
    useRoutingFeatures = "server";
  };
}
