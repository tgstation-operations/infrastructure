{
  pkgs,
  config,
  ...
}: let
  deployUsers = import ./ssh_keys.nix;
in {
  # Configuration required to use github actions to deploy to nodes
  users.users.deploy = {
    isNormalUser = true;

    extraGroups = [
      "wheel" # Needed for nixos-rebuild. Originally the idea was to just limit it to a group and setup sudo to allow nixos-rebuild as that user, but that would result in them being able to modify system.activationScripts regardless and run scripts as root, so it's not very useful
    ];

    group = "deploy";
    openssh.authorizedKeys.keys =
      deployUsers
      ++ [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL9Pizmnyye3CmgonAAzdVBeiVUyXs+pk8LFPAaUFnVi deploy@tgstation-infra-staging"
      ];
  };

  users.groups.deploy = {};
  nix.settings = {
    # Allow our user to use binary caches during builds explicitly
    trusted-users = [
      "deploy"
    ];
  };
}
