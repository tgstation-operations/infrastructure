{lib, ...}: {
  services.openssh = {
    enable = true;
    allowSFTP = true;
    settings = {
      PermitRootLogin = lib.mkForce "no";
      PasswordAuthentication = lib.mkForce false;
      KbdInteractiveAuthentication = lib.mkForce false;
      ChallengeResponseAuthentication = lib.mkForce false;
      LogLevel = "VERBOSE";
    };
    extraConfig = ''
      AuthenticationMethods publickey
    '';
  };
}
