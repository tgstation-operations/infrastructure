{pkgs, ...}: {
  programs.rust-motd = {
    settings.banner = {
      color = "red";
      command = "${pkgs.bash}/bin/bash ${./tgsatan_banner.sh}";
    };
  };
}
