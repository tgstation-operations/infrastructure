{pkgs, ...}: {
  programs.rust-motd = {
    settings.banner = {
      color = "blue";
      command = "${pkgs.bash}/bin/bash ${./banner.sh}";
    };
  };
}
