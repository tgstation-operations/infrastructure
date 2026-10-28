{config, ...}: let
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
        static_configs = [{targets = ["127.0.0.1:9400"];}];
      }
      {
        job_name = "caddy";
        static_configs = [{targets = ["127.0.0.1:2019"];}];
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
              "tgsatan.tg.internal:${systemdPromPort}"
              "blockmoths.tg.internal:${systemdPromPort}"
              "wiggle.tg.internal:${systemdPromPort}"
              "vpn.tg.internal:${systemdPromPort}"
            ];
          }
        ];
      }
      {
        job_name = "stats core servers";
        static_configs = [
          {
            targets = [
              "tgsatan.tg.internal:${nodeExporterPort}"
              "blockmoths.tg.internal:${nodeExporterPort}"
              "wiggle.tg.internal:${nodeExporterPort}"
              "vpn.tg.internal:${nodeExporterPort}"
            ];
          }
        ];
      }
      {
        job_name = "haproxy game servers";
        static_configs = [
          {
            targets = [
              "tgsatan.tg.internal:${haproxyPromPort}"
              "blockmoths.tg.internal:${haproxyPromPort}"
              "wiggle.tg.internal:${haproxyPromPort}"
            ];
          }
        ];
      }
      {
        job_name = "TGS servers";
        static_configs = [
          {
            targets = [
              "tgsatan.tg.internal:${tgsPromPort}"
              "blockmoths.tg.internal:${tgsPromPort}"
              "wiggle.tg.internal:${tgsPromPort}"
            ];
          }
        ];
      }
      {
        job_name = "GitHub Webhook PR Announcer";
        static_configs = [
          {
            targets = [
              "lemon.tg.internal:${prAnnouncerPort}"
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
                "warsaw.tg.internal:${nodeExporterPort}"
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
                "warsaw.tg.internal:${haproxyPromPort}"
              ]
              ++ (import ./relay-nodes.nix) haproxyPromPort;
          }
        ];
      }
    ];
  };
}
