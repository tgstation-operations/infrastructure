{
  config,
  pkgs,
  lib,
  ...
}: let
  name = "tgtts";
  port = 5011;
  source-directory = "/persist/flakes/tgtts2/fish-speech";
  workspace-directory = "/persist/tgtts2-blips";
  build-service-name = "${name}-build";
  haproxy-cfg = pkgs.writeTextFile {
    name = "tgtts-haproxy.cfg";
    text = builtins.readFile ./haproxy.cfg;
  };
  compose-file = pkgs.writeTextFile {
    name = "tgtts-docker-compose.yml";
    text = builtins.replaceStrings [ "$TGTTS_HAPROXY_CFG_PATH$" "$TGTTS_BLIPS_PATH$" "$TGTTS_IMAGE_NAME$" "$TGTTS_PUBLIC_PORT$" ] [ "${haproxy-cfg}" workspace-directory name "${toString port}" ] (builtins.readFile ./docker-compose.yml);
  };
in {
  users = {
    users."${name}" = {
      group = name;
      linger = true;
    };

    groups."${name}" = {};
  };

  systemd.user.services = {
    "${build-service-name}" = {
      enable = true;
      unitConfig.ConditionUser = name;
      description = "tgstation TTS Server Image Build";
      requires = [ "docker.service" ];
      after = [ "docker.service" ];
      serviceConfig = {
        Type = "oneshot";
        User = name;
        ExecStart = pkgs.writeShellScript "tg-tts-build.sh" ''
          if [ -z "$(${pkgs.docker}/bin/docker images -q ${name} 2> /dev/null)" ]; then
            echo "${name} image needs to be built"
            exec ${pkgs.docker}/bin/docker build ${source-directory} -t ${name}
          else
            echo "${name} image looks to be built already"
          fi
        '';
      };
      wantedBy = ["multi-user.target"];
    };
    "${name}" = {
      enable = true;
      unitConfig.ConditionUser = name;
      description = "tgstation TTS Server";
      requires = [ "docker.service" "${build-service-name}.service" ];
      after = [ "docker.service" "${build-service-name}.service" ];
      serviceConfig = {
        Type = "simple";
        User = name;
        ExecStart = "${pkgs.docker}/bin/docker compose -f ${compose-file} up";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
