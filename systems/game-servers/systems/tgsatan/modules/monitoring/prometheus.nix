{
  config,
  pkgs,
  ...
}: let
  systemdPromPort = toString config.services.prometheus.exporters.systemd.port;
  nodeExporterPort = toString config.services.prometheus.exporters.node.port;
  # Needs to be moved into a common config
  tgsPromPort = "5001";
  prAnnouncerPort = "5004";
  # The following is already a string, so no need to convert it
  haproxyPromPort = config.systemd.services.haproxy.environment.PROMETHEUS_PORT;
in {
  services.prometheus = {
    enable = true;
    globalConfig.scrape_interval = "10s";
    scrapeConfigs = [
      {
        job_name = "tgsatan_gpu_1";
        static_configs = [{targets = ["tgsatan.tg.lan:9400"];}];
      }
      {
        job_name = "caddy";
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
              "tgsatan.tg.lan:${systemdPromPort}"
              "blockmoths.tg.lan:${systemdPromPort}"
              "wiggle.tg.lan:${systemdPromPort}"
              "vpn.tg.lan:${systemdPromPort}"
            ];
          }
        ];
      }
      {
        job_name = "stats core servers";
        static_configs = [
          {
            targets = [
              "tgsatan.tg.lan:${nodeExporterPort}"
              "blockmoths.tg.lan:${nodeExporterPort}"
              "wiggle.tg.lan:${nodeExporterPort}"
              "vpn.tg.lan:${nodeExporterPort}"
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
        job_name = "TGS servers";
        static_configs = [
          {
            targets = [
              "tgsatan.tg.lan:${tgsPromPort}"
              "blockmoths.tg.lan:${tgsPromPort}"
              "wiggle.tg.lan:${tgsPromPort}"
            ];
          }
        ];
      }
      {
        job_name = "GitHub Webhook PR Announcer";
        static_configs = [
          {
            targets = [
              "tgsatan.tg.lan:${prAnnouncerPort}"
            ];
          }
        ];
      }
      # {
      #   job_name = "systemd relay node";
      #   static_configs = [
      #     {
      #       targets =
      #         [
      #           "warsaw.tg.lan:${systemdPromPort}"
      #         ]
      #         ++ (import ./relay-nodes.nix) systemdPromPort;
      #     }
      #   ];
      # }
      {
        job_name = "stats relay node";
        static_configs = [
          {
            targets =
              [
                "warsaw.tg.lan:${nodeExporterPort}"
              ]
              ++ (import ./relay-nodes.nix) nodeExporterPort;
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
