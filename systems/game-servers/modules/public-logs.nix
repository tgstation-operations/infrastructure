{
  logs-location,
  server-name,
  serve-address,
  pkgs,
  group ? "tgstation-server",
  ...
}: {
  services.tg-public-log-parser."${server-name}" = {
    enable = true;
    supplementary-groups = group;
    config = {
      raw_logs_path = logs-location;
      address = serve-address;
      ongoing_round_protection = {
        serverinfo = "https://tgstation13.org/serverinfo.json";
      };
    };
  };
}
