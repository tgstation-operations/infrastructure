{
  config,
  pkgs,
  ...
}: {
  pkgs.dragonflydb = pkgs.stdenv.mkDerivation {
    pname = "dragonflydb";
    version = "1.27.1";
    src = pkgs.fetchFromGitHub {
      owner = "dragonflydb";
      repo = "dragonfly";
      tag = "v1.27.1";
    };
    nativeBuildInputs = with pkgs; [
      autoconf
      autoconf-archive
      automake
      cmake
      ninja
    ];
    buildInputs = with pkgs; [
      boost
      libunwind
      libtool
      openssl
    ];
    cmakeFlags = with pkgs; [
      "-DCMAKE_AR=${gcc-unwrapped}/bin/gcc-ar"
      "-DCMAKE_RANLIB=${gcc-unwrapped}/bin/gcc-ranlib"
    ];
    ninjaFlags = ["dragonfly"];
    postPatch = with pkgs; ''
      mkdir -p ./build/{third_party,_deps}
      ln -s ${double-conversion.src} ./build/third_party/dconv
      ln -s ${mimalloc.src} ./build/third_party/mimalloc
      ln -s ${rapidjson.src} ./build/third_party/rapidjson
      ln -s ${gbenchmark.src} ./build/_deps/benchmark-src
      ln -s ${gtest.src} ./build/_deps/gtest-src
      cp -R --no-preserve=mode,ownership ${gperftools.src} ./build/third_party/gperf
      cp -R --no-preserve=mode,ownership ${liburing.src} ./build/third_party/uring
      cp -R --no-preserve=mode,ownership ${xxHash.src} ./build/third_party/xxhash
      cp -R --no-preserve=mode,ownership ${abseil-cpp_202111} ./build/_deps/abseil_cpp-src
      cp -R --no-preserve=mode,ownership ${glog.src} ./build/_deps/glog-src
      chmod u+x ./build/third_party/uring/configure
      cp ./build/third_party/xxhash/cli/xxhsum.{1,c} ./build/third_party/xxhash
      sed '
      s@REPLACEJEMALLOCURL@file://${jemalloc.src}@
      s@REPLACELUAURL@file://${lua}@
      ' ${./fixes.patch} | patch -p1
    '';
    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp ./dragonfly $out/bin
      runHook postInstall
    '';
  };

  services.dragonflydb = {
    enable = true;
  };
}
