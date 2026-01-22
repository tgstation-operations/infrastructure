{ pkgs, ... }: {
  services.alloy = {
    enable = true;
    configPath = pkgs.writeText "config.alloy" ''
      loki.relabel "journal" {
        forward_to = []

        rule {
          source_labels = ["__journal__systemd_unit"]
          target_label = "unit"
        }
      }

      loki.source.journal "read"  {
        forward_to = [loki.write.endpoint.receiver]
        relabel_rules = loki.relabel.journal.rules
        labels = {component = "loki.source.journal"}
      }

      loki.write "endpoint" {
        endpoint {
          url = "tgsatan.tg.lan:3100/api/v1/push"
        }
      }
    '';
  };
}
