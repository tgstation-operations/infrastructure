let
  users = import ../modules/ssh_keys_by_group.nix {};
  systems = import ../modules/ssh_keys_systems.nix;
  final = users ++ systems.all;
in {
  # Go to https://dash.cloudflare.com/profile/api-tokens, Create Token at the top, Edit zone DNS template
  # Currently using a personal token from Dominion's account, should eventually changed to a tgstation13.org account token
  "cloudflare-api.age".publicKeys = final;
}
