{self, ...}: let
  dummy-array = [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19];

  count-blips = 1;
  count-api = 2;
  count-hubert = 2;
  count-rvc = 7;
  count-vits = 5;

  attributes-blips = builtins.map (id: {
    name = "tgtts-blips-" + (builtins.toString id);
    value = {
      hostname = "tgtts-blips-" + (builtins.toString id);
      image = "tgtts/latest";
      imageFile = self.inputs.tts-api.packages.x86_64-linux.docker-image;
      volumes = [
        "/persist/tgtts:/var/lib/tgtts"
      ];
    };
  }) (builtins.filter (id: id < count-blips) dummy-array);

  attributes-api = builtins.map (id: {
    name = "tgtts-api-" + (builtins.toString id);
    value = {
      hostname = "tgtts-api-" + (builtins.toString id);
      image = "tgtts/latest";
      imageFile = self.inputs.tts-api.packages.x86_64-linux.docker-image;
      volumes = [
        "/persist/tgtts:/var/lib/tgtts"
      ];
    };
  }) (builtins.filter (id: id < count-api) dummy-array);

  attributes-hubert = builtins.map (id: {
    name = "tgtts-hubert-" + (builtins.toString id);
    value = {
      hostname = "tgtts-hubert-" + (builtins.toString id);
      image = "tgtts/latest";
      imageFile = self.inputs.tts-api.packages.x86_64-linux.docker-image;
      volumes = [
        "/persist/tgtts:/var/lib/tgtts"
      ];
    };
  }) (builtins.filter (id: id < count-hubert) dummy-array);

  attributes-rvc = builtins.map (id: {
    name = "tgtts-rvc-" + (builtins.toString id);
    value = {
      hostname = "tgtts-rvc-" + (builtins.toString id);
      image = "tgtts/latest";
      imageFile = self.inputs.tts-api.packages.x86_64-linux.docker-image;
      volumes = [
        "/persist/tgtts:/var/lib/tgtts"
      ];
    };
  }) (builtins.filter (id: id < count-rvc) dummy-array);

  attributes-vits = builtins.map (id: {
    name = "tgtts-vits-" + (builtins.toString id);
    value = {
      hostname = "tgtts-vits-" + (builtins.toString id);
      image = "tgtts/latest";
      imageFile = self.inputs.tts-api.packages.x86_64-linux.docker-image;
      volumes = [
        "/persist/tgtts:/var/lib/tgtts"
      ];
    };
  }) (builtins.filter (id: id < count-vits) dummy-array);
in {
  virtualisation.oci-containers = {
    backend = "podman";
    containers = builtins.listToAttrs (attributes-blips ++ attributes-api ++ attributes-hubert ++ attributes-rvc ++ attributes-vits);
  };
}
