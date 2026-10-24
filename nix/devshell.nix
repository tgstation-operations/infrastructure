{
  pkgs,
  inputs,
  fmt,
  audit,
}: let
  inherit (pkgs.stdenv.hostPlatform) system;
in
  pkgs.mkShell {
    packages = [
      inputs.agenix.packages.${system}.default
      inputs.colmena.packages.${system}.colmena
      inputs.alejandra.defaultPackage.${system}
      pkgs.jq
      fmt
      audit
    ];

    shellHook = ''
      # Ahead of coreutils, whose fmt is a paragraph reflower.
      export PATH="${pkgs.lib.makeBinPath [fmt audit]}:$PATH"
      git config blame.ignoreRevsFile .git-blame-ignore-revs 2>/dev/null || true
    '';
  }
