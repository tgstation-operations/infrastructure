let
  users = import ../../../../../modules/ssh_keys.nix;

  # Systems
  wiggle = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILz3vKC6Xr5fmXXU8BsY5oityIM60NmIaCyPTPUuZ35+";
  systems = [wiggle];
in {
  # TGS
  "tgs.age".publicKeys = users ++ systems;
  # Cloudflare DNS-01
  "cloudflare_api.age".publicKeys = users ++ systems;
}
