let
  users = import ../../../modules/ssh_keys_by_group.nix {};
  systems = import ../../../modules/ssh_keys_systems.nix;
  final = users ++ [systems.vpn];
in {
  # head -c 32 /dev/urandom | base64, the encoding NetBird expects for both keys
  "netbird-datastore-key.age".publicKeys = final;
  "netbird-idp-cookie-key.age".publicKeys = final;
  "netbird-relay-secret.age".publicKeys = final;
  # The dashboard owner's login password, and its htpasswd -inBC 12 "" hash without the leading colon
  "netbird-owner-password.age".publicKeys = users;
  "netbird-owner-hash.age".publicKeys = final;
}
