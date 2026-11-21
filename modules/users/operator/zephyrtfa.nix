{
  pkgs,
  ...
}: {
  users.users.zephyrtfa = {
    shell = pkgs.fish;
    isNormalUser = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBWWfCrgbiXe608weuYqyakrXXeLQQZSLatp1qVDjdiX derg@framework"
    ];

    extraGroups = [
      "wheel"
      "db-operator"
    ];
  };
}
