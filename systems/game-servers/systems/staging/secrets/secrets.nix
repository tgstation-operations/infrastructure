let
  users = import ../../../../../modules/ssh_keys_by_group.nix;
  wiggle = (import ../../../../../modules/ssh_keys_system.nix).wiggle;
  final = users ++ [wiggle];
in {
  # TGS
  "tgs.age".publicKeys = final;
  # Cloudflare DNS-01
  "cloudflare_api.age".publicKeys = final;
}
