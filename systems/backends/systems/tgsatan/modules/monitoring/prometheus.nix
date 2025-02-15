{
  config,
  pkgs,
  ...
}: let
  promPort = toString config.services.prometheus.exporters.systemd.port;
  # TODO: move into a shared variable
  haproxyPromPort = "8405";
in {
  services.prometheus = {
    enable = true;
    globalConfig.scrape_interval = "10s";
    scrapeConfigs = [
      {
        job_name = "tgsatan_node";
        static_configs = [
          {targets = ["tgsatan.tg.lan:${toString config.services.prometheus.exporters.node.port}"];}
        ];
      }
      {
        job_name = "tgsatan_gpu_1";
        static_configs = [{targets = ["tgsatan.tg.lan:9400"];}];
      }
      {
        job_name = "tgsatan_caddy";
        static_configs = [{targets = ["tgsatan.tg.lan:2019"];}];
      }
      # {
      #  job_name = "tgsatan_forgejo";
      #  static_configs [ { targets= [ "tgsatan.tg.lan:9001" ]; } ];
      # }
      {
        job_name = "systemd core servers";
        static_configs = [
          {
            targets = [
              "tgsatan.tg.lan:${promPort}"
              "blockmoths.tg.lan:${promPort}"
              "wiggle.tg.lan:${promPort}"
              "vpn.tg.lan:${promPort}"
            ];
          }
        ];
      }
      {
        job_name = "haproxy game servers";
        static_configs = [
          {
            targets = [
              "tgsatan.tg.lan:${haproxyPromPort}"
              "blockmoths.tg.lan:${haproxyPromPort}"
              "wiggle.tg.lan:${haproxyPromPort}"
            ];
          }
        ];
      }
      {
        job_name = "systemd relay node";
        static_configs = [
          {
            targets =
              [
                "warsaw.tg.lan:${promPort}"
              ]
              ++ (import ./relay-nodes.nix) promPort;
          }
        ];
      }
      {
        job_name = "haproxy relay node";
        static_configs = [
          {
            targets =
              [
                "warsaw.tg.lan:${haproxyPromPort}"
              ]
              ++ (import ./relay-nodes.nix) haproxyPromPort;
          }
        ];
      }
    ];
  };
}
