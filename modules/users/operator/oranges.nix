{...}: {
  users.users.oranges = {
    isNormalUser = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAgajX1HkV35OT8euEj7icnN9Ifr3Y44WqRo8ympL4Zw oranges@venus"
    ];

    extraGroups = [
      "redbot-user"
      "wheel"
    ];
  };
}
