{...}: {
  users.users.watermelon = {
    isNormalUser = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF2jirfKoXgWE4UVUdmzCmv57VsRIrQWKcD9LDeRj8Vj watermelon@desktop-yellowsea"
    ];
  };
}
