{...}: {
  users.users.aiia = {
    isNormalUser = true;
    shell = "/bin/nologin";

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPYBQelpKQdyU+m/Cp5Fhrf5ME21zVbZTsOBO4tWDszz"
    ];
  };
}
