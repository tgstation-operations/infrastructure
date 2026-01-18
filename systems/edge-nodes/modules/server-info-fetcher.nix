{
  inputs,
  ...
}: {
  imports = [
    inputs.server-info-fetcher.nixosModules.default
  ];

  services.tgstation-server-info-fetcher = {
    enable = true;
    groupname = "caddy";
    servers = [
      "blockmoths.tg.lan:3336"
      "tgsatan.tg.lan:1337"
      "tgsatan.tg.lan:1447"
      "tgsatan.tg.lan:5337"
      "tgsatan.tg.lan:7337"
      "tgsatan.tg.lan:7777"
    ];
  };
}
