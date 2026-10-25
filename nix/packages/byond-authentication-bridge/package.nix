{
  buildNpmPackage,
  fetchFromGitHub,
  prisma-engines_6,
  rustPlatform,
}: let
  # Prisma's CLI and client come from bab's package-lock.json, and need engines
  # of the same version.
  prisma-engines = prisma-engines_6.overrideAttrs (finalAttrs: previousAttrs: {
    version = "6.4.1";
    src = fetchFromGitHub {
      owner = "prisma";
      repo = "prisma-engines";
      tag = finalAttrs.version;
      hash = "sha256-X7HR0C8Yu34lCuGsCXzhQ8+i1NsTx9dRt9eHa0aHmnc=";
    };
    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (finalAttrs) pname version src patches;
      hash = "sha256-3nTNfoTswEpDmInoSC9EjyJFRg6sXtz8AZMkqc7o2tQ=";
    };
  });
  prismaEnv = {
    PRISMA_QUERY_ENGINE_LIBRARY = "${prisma-engines}/lib/libquery_engine.node";
    PRISMA_SCHEMA_ENGINE_BINARY = "${prisma-engines}/bin/schema-engine";
  };
in
  buildNpmPackage {
    pname = "byond-authentication-bridge";
    version = "1.0.0";
    src = fetchFromGitHub {
      owner = "alexkar598";
      repo = "bab";
      rev = "7f8c0572b3b546523a65246e14e9d80f6b20cf03";
      hash = "sha256-8jb08XbHu3padD7kfnmuxGFkSCqxdGHB+yZ8/u7ddU8=";
    };
    # bab's hourly timers otherwise keep it running after SIGTERM, until systemd
    # gives up and kills it.
    patches = [./unref-intervals.patch];
    npmDepsHash = "sha256-dK8gACPM9GIZS5GvDfsssHm8+Y7IPY9AVI6d9gC7Myo=";
    env = prismaEnv;
    preBuild = ''
      prisma_version=$(node -p 'require("prisma/package.json").version')
      if [ "$prisma_version" != ${prisma-engines.version} ]; then
        echo "bab pins prisma $prisma_version, but the engines are ${prisma-engines.version}" >&2
        exit 1
      fi
      sed -i 's/"name": "bab",/"name": "bab","bin":{"bab":"dist\/index.js"},/g' package.json
      npm run generateDbClient
    '';
    passthru = {inherit prismaEnv;};
  }
