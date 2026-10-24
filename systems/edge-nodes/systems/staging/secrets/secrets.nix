let
  users = import ../../../../../modules/ssh_keys_by_group.nix {};
  inherit (import ../../../../../modules/ssh_keys_systems.nix) warsaw;
  final = users ++ [warsaw];
in {
  "tailscaleAuthKey.age".publicKeys = final;
}
