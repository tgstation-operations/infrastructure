{pkgs, ...}: {
  programs.rust-motd = {
    settings.banner = {
      color = "light_magenta";
      command = "${pkgs.bash}/bin/bash ${./blockmoths_banner.sh}";
    };
  };
}
