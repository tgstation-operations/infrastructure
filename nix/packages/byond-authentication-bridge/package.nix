{
  buildNpmPackage,
  fetchFromGitHub,
  jq,
  prisma,
  prisma-engines,
  runCommand,
}: let
  source = fetchFromGitHub {
    owner = "alexkar598";
    repo = "bab";
    rev = "7f8c0572b3b546523a65246e14e9d80f6b20cf03";
    hash = "sha256-8jb08XbHu3padD7kfnmuxGFkSCqxdGHB+yZ8/u7ddU8=";
  };
  prisma-version = runCommand "prisma-version" {} ''
    cat ${source}/package-lock.json | ${jq}/bin/jq -r '.packages."node_modules/prisma".version' > $out
  '';
  prisma' = prisma.overrideAttrs (finalAttrs: previousAttrs: {
    version = builtins.readFile prisma-version;
    __intentionallyOverridingVersion = true;
  });
  prisma-engines' = prisma-engines.overrideAttrs (finalAttrs: previousAttrs: {
    version = builtins.readFile prisma-version;
    __intentionallyOverridingVersion = true;
  });
in
  buildNpmPackage {
    pname = "byond-authentication-bridge";
    version = "1.0.0";
    src = source;
    npmDepsHash = "sha256-dK8gACPM9GIZS5GvDfsssHm8+Y7IPY9AVI6d9gC7Myo=";
    preBuild = ''
      sed -i 's/"name": "bab",/"name": "bab","bin":{"bab":"dist\/index.js"},/g' package.json
      sed -i 's/  provider = "prisma-client-js"/  provider = "prisma-client-js"\n  binaryTargets = [ "native" ]/g' prisma/schema.prisma
      export PRISMA_QUERY_ENGINE_BINARY="${prisma-engines'}/bin/query-engine"
      export PRISMA_QUERY_ENGINE_LIBRARY="${prisma-engines'}/lib/libquery_engine.node"
      export PRISMA_INTROSPECTION_ENGINE_BINARY="${prisma-engines'}/bin/introspection-engine"
      export PRISMA_FMT_BINARY="${prisma-engines'}/bin/prisma-fmt"
      ${prisma'}/bin/prisma generate
    '';
    passthru.prisma-engines = prisma-engines';
  }
