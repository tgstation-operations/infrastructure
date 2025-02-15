(
  portNum:
    builtins.filter
    (x: x != "")
    (builtins.attrValues
      (builtins.mapAttrs
        (
          name: values:
            if
              (builtins.hasAttr "deployment" values)
              && (builtins.hasAttr "tags" values.deployment)
              && (builtins.elem "relay" values.deployment.tags)
            then values.deployment.targetHost + ":" + (toString portNum)
            else ""
        )
        (
          (import ../../../../../../flake.nix).outputs
          {
            self = {};
            nixpkgs = {};
            alejandra = {};
            nixpkgs-unstable = {};
            colmena = {};
            fenix = {};
          }
        )
        .colmena))
)
