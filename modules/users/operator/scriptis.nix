{pkgs, ...}: {
  users.users.scriptis = {
    isNormalUser = true;

    initialHashedPassword = "$y$j9T$sO2rV8ARIx2AOr6Z5DlKj.$s/18HTYZ.5v6xxkhTd0mWs2MHdUCLzoaWf.L0BIx4v0";

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILPyASt6VXR03toSHdcBG05m46EhbpcJjqL0GZTr04hC dt@prospekt"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMTj5m77SEtl0bcOLJr5J1sJwPqo61Zt7aTg21tu7zlI u0_a189@localhost"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFY6r4+3CtoTH492mQ2ixC4u39MOUd/l3Pgy/D/wKqIf cardno:13_456_426"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIqaQ0bgwIgVxnql5VcT3Sh7o5HugjgXypNpwCFnCc/C dt@grob"
    ];

    extraGroups = [
      "wheel"
      "docker"
      "db-operator"
    ];

    shell = pkgs.fish;
  };
}
