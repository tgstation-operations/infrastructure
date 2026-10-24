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
      pkgs.colmena
      pkgs.alejandra
      pkgs.deadnix
      pkgs.jq
      pkgs.statix
      pkgs.zola
      fmt
      audit
    ];

    shellHook = ''
      # Ahead of coreutils, whose fmt is a paragraph reflower.
      export PATH="${pkgs.lib.makeBinPath [fmt audit]}:$PATH"
      git config core.hooksPath .githooks 2>/dev/null || true
      git config blame.ignoreRevsFile .git-blame-ignore-revs 2>/dev/null || true
    '';
  }
