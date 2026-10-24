{pkgs, ...}: let
  inherit (pkgs) stdenv lib;

  version = "6.18.0";

  fixedOutput = stdenv.mkDerivation {
    pname = "tgstation-server-release-server-console-zip";
    inherit version;

    meta = with pkgs.lib; {
      description = "Host watchdog binaries for tgstation-server";
      homepage = "https://github.com/tgstation/tgstation-server";
      changelog = "https://github.com/tgstation/tgstation-server/releases/tag/tgstation-server-v${version}";
      license = licenses.agpl3Plus;
      platforms = platforms.x86_64;
    };

    nativeBuildInputs = with pkgs; [
      curl
      cacert
    ];

    dontUnpack = true;

    buildPhase = ''
      curl -L https://github.com/tgstation/tgstation-server/releases/download/tgstation-server-v${version}/ServerConsole.zip -o ServerConsole.zip
    '';

    installPhase = ''
      mkdir -p $out
      mv ServerConsole.zip $out/ServerConsole.zip
    '';

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-tHe8NQFSf6omeSduqCq4FrE0Jy64HXNeEZ8kNCZkUgE=";
  };
in
  stdenv.mkDerivation {
    pname = "tgstation-server";
    inherit version;

    meta = with pkgs.lib; {
      description = "A production scale tool for DreamMaker server management";
      homepage = "https://github.com/tgstation/tgstation-server";
      changelog = "https://github.com/tgstation/tgstation-server/releases/tag/tgstation-server-v${version}";
      license = licenses.agpl3Plus;
      platforms = platforms.x86_64;
    };

    buildInputs = with pkgs; [
      dotnetCorePackages.sdk_8_0
      gdb
      systemd
      zlib
      gcc_multi
      glibc
      bash
    ];
    nativeBuildInputs = with pkgs; [
      makeWrapper
      unzip
      fixedOutput
    ];

    dontUnpack = true;

    passthru.serverConsole = fixedOutput;

    installPhase = ''
      mkdir -p $out/bin
      unzip "${fixedOutput}/ServerConsole.zip" -d $out/bin
      rm -rf $out/bin/lib
      makeWrapper ${pkgs.dotnetCorePackages.sdk_8_0}/bin/dotnet $out/bin/tgstation-server --suffix PATH : ${
        lib.makeBinPath (
          with pkgs; [
            dotnetCorePackages.sdk_8_0
            gdb
            bash
          ]
        )
      } --suffix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath (
          with pkgs; [
            systemd
            zlib
          ]
        )
      } --add-flags "$out/bin/Tgstation.Server.Host.Console.dll --bootstrap"
    '';
  }
