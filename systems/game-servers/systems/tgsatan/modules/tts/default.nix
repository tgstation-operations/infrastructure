{
  config,
  pkgs,
  lib,
  ...
}: let
  source-directory = "/persist/flakes/tgtts2/fish-speech";
  name = "tgtts";
  build-service-name = "${name}-build";
  compose = builtins.readFile ./docker-compose.yml;
in {
  users = {
    users."${usergroup-name}" = {
      group = usergroup-name;
      isSystemUser = true;
    };

    groups."${usergroup-name}" = {};
  };

  systemd.services = {
    "${build-service-name}" = {
      enable = true;
      description = "tgstation TTS Server Image Build";
      requires = [ "docker.service" ];
      after = [ "docker.service" ];
      serviceConfig = {
        Type = "oneshot";
        User = usergroup-name;
        ExecStart = pkgs.writeShellScript "tg-tts-build.sh" ''
          if [ -z "$(${pkgs.docker}/bin/docker images -q ${image-name} 2> /dev/null)" ]; then
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
      description = "tgstation TTS Server";
      requires = [ "docker.service" "${build-service-name}.service" ];
      after = [ "docker.service" "${build-service-name}.service" ];
      serviceConfig = {
        Type = "simple";
        User = usergroup-name;
        ExecStart = "${pkgs.docker}/bin/docker compose -f ${compose} up";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
