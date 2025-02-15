let
  users = import ../../../../../modules/ssh_keys.nix;

  # Systems
  warsaw = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAendJQ8VvBhnLl5Us7Q/2X9o6LSy8Ec7nXhs1JvLF3k";
  systems = [warsaw];
in {
  "cloudflare_api.age".publicKeys = users ++ systems;
  "tailscaleAuthKey.age".publicKeys = users ++ systems;
}
