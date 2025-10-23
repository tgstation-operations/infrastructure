let
  users = import ../../../../../modules/ssh_keys_by_group.nix {};
  warsaw = (import ../../../../../modules/ssh_keys_systems.nix).warsaw;
  final = users ++ [warsaw];
in {
  "cloudflare-api.age".publicKeys = final;
  "tailscaleAuthKey.age".publicKeys = final;
}
