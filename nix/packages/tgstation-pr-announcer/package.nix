{pkgs, ...}:
pkgs.buildDotnetModule {
  pname = "tgstation-pr-announcer";
  version = "1.0.0";

  meta = with pkgs.lib; {
    description = "Tool for forwarding GitHub webhooks for PRs to DM game servers";
    homepage = "https://github.com/tgstation/tgstation";
    license = licenses.agpl3Plus;
    platforms = platforms.x86_64;
  };

  src = pkgs.fetchFromGitHub {
    owner = "tgstation";
    repo = "tgstation";
    rev = "be9ae13cd50cc2f2f6680883424b86feb3c22725";
    rootDir = "tools/Tgstation.PRAnnouncer";
    hash = "sha256-mzAy1/Tjy+aSr+0RkV4Lfe96WAkrlmx1nQwYQCG4vN8=";
  };

  projectFile = "Tgstation.PRAnnouncer.csproj";
  nugetDeps = ./deps.json;

  dotnet-sdk = pkgs.dotnetCorePackages.sdk_8_0;
  dotnet-runtime = pkgs.dotnetCorePackages.aspnetcore_8_0;

  executables = ["Tgstation.PRAnnouncer"];
}
