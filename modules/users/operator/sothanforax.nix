{pkgs, ...}: {
  users.users.sothanforax = {
    # I am bad at coming up with usernames and I don't feel like bothering with my local one, as much as dmr needs his respects paid.
    isNormalUser = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHdsT+cVuNnaCX+IJtsJ/h++DhYaS+TvwVoeFkFiTHo8 mk@Manganese"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINMioHFvfZt/v3I3K02DENMvj+CQLOUDdlkIVwxbYBIr u0_a325@localhost"
    ];

    extraGroups = [
      "wheel"
    ];

    shell = pkgs.zsh;

    packages = with pkgs; [
      vim
      btop
      fzf
      tshark
    ];
  };
}
