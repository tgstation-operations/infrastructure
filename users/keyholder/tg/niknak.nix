{...}: {
  users.users.niknak = {
    isNormalUser = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJaYV8oQc4gEXw8xx04RbvqeBxoGTexnr9w/eZB5lp0K Nik@DESKTOP-1H1LLTB"
    ];
  };
}
