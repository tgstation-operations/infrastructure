let
  users = import ../../../../../modules/ssh_keys.nix;
  warsaw = (import ../../../../../modules/ssh_keys_system.nix).warsaw;
  final = users ++ [warsaw];
in {
  "cloudflare_api.age".publicKeys = final;
  "tailscaleAuthKey.age".publicKeys = final;
}
