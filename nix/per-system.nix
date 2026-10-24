{
  pkgs,
  inputs,
}: let
  alejandra = inputs.alejandra.defaultPackage.${pkgs.stdenv.hostPlatform.system};
  fmt = import ./scripts/fmt.nix {inherit pkgs alejandra;};
  audit = import ./scripts/audit.nix {inherit pkgs fmt;};
in {
  packages = {inherit fmt audit;};
  devShell = import ./devshell.nix {inherit pkgs inputs fmt audit;};
  checks = pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isx86_64 {
    rollback-root = import ./tests/rollback-root.nix {inherit pkgs inputs;};
  };
}
