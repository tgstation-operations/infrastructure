{pkgs, ...}: {
  users.users.riggle = {
    isNormalUser = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDtHz4KGrjtIim0NzdYDu9T3Olcw9Ks5G+aDDHBEurkl riggle@Saiph"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMiO7rXqxAQKSBq46QVL5fD60FqhSA3Sa/schrDsQcv1 riggle@mintaka"
    ];

    extraGroups = [
      "wheel"
      "db-operator"
    ];

    shell = pkgs.zsh;

    packages = with pkgs; [
      bat
      doggo
      jq
      tshark
      zoxide
    ];
  };
}
