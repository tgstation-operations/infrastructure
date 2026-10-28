let
  users = import ../../../modules/ssh_keys_by_group.nix {};
  inherit (import ../../../modules/ssh_keys_systems.nix) vpn;
  final = users ++ [vpn];
in {
  # AWS_ACCESS_KEY_ID=<id> and AWS_SECRET_ACCESS_KEY=<key>, on lines of their own, for the opentofu-deployer
  # IAM user, which has full Route53 and S3 access: the us and eu zones, and the state bucket.
  "aws.age".publicKeys = final;
  # TF_VAR_state_passphrase=<passphrase> that OpenTofu encrypts its state with, from openssl rand -base64 32.
  "state-passphrase.age".publicKeys = final;
}
