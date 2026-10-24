{
  pkgs,
  inputs,
}: let
  inherit (pkgs) alejandra;
  fmt = import ./scripts/fmt.nix {inherit pkgs alejandra;};
  audit = import ./scripts/audit.nix {inherit pkgs fmt;};
in {
  packages = {
    inherit fmt audit;
    tgstation-website = pkgs.callPackage ./packages/tgstation-website/package.nix {};
  };
  devShell = import ./devshell.nix {inherit pkgs inputs fmt audit;};
  checks = pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isx86_64 {
    rollback-root = import ./tests/rollback-root.nix {inherit pkgs inputs;};
    tgstation-server = import ./tests/tgstation-server.nix {inherit pkgs inputs;};
    byond-authentication-bridge = import ./tests/byond-authentication-bridge.nix {inherit pkgs;};
  };
}
