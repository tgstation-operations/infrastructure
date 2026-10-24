{
  lib,
  runCommand,
  zola,
}: let
  root = ../../../website;
  # Only what Zola reads: the mock server data beside it stays out of the site.
  src = lib.fileset.toSource {
    inherit root;
    fileset = lib.fileset.unions (map (lib.path.append root) [
      "config.toml"
      "content"
      "sass"
      "static"
      "templates"
    ]);
  };
in
  runCommand "tgstation-website" {nativeBuildInputs = [zola];} ''
    zola --root ${src} build --output-dir $out
  ''
