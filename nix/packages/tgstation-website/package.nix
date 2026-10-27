{
  lib,
  buildNpmPackage,
  importNpmLock,
}: let
  root = ../../../website;
  # Only what Eleventy reads: the mock server data beside it stays out of the site.
  src = lib.fileset.toSource {
    inherit root;
    fileset = lib.fileset.unions (map (lib.path.append root) [
      "eleventy.config.js"
      "package-lock.json"
      "package.json"
      "src"
    ]);
  };
in
  buildNpmPackage {
    name = "tgstation-website";
    inherit src;
    npmDeps = importNpmLock {npmRoot = src;};
    inherit (importNpmLock) npmConfigHook;
    installPhase = ''
      runHook preInstall
      cp -r _site $out
      runHook postInstall
    '';
  }
