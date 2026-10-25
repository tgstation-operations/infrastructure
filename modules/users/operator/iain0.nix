{pkgs, ...}: {
  users.users.iain0 = {
    isNormalUser = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBCaat3EUVrqal/XlY2e4mgXFhX/Izp7H+C/i32feW4P"
    ];

    extraGroups = [
      "wheel"
    ];
    shell = pkgs.fish;
  };
}
