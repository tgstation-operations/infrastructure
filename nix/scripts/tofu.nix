{
  pkgs,
  agenix,
}:
pkgs.writeShellApplication {
  name = "tofu";
  runtimeInputs = [
    (pkgs.opentofu.withPlugins (p: [
      p.hashicorp_aws
      p.cloudflare_cloudflare
      (pkgs.callPackage ../packages/terraform-provider-netbird/package.nix {})
    ]))
    agenix
    pkgs.git
  ];
  text = ''
    root=$(git rev-parse --show-toplevel)
    # agenix finds the recipients in the secrets.nix of its working directory.
    decrypt() {
      (cd "$root/$1" && agenix -d "$2")
    }

    CLOUDFLARE_API_TOKEN=$(decrypt secrets cloudflare-api.age)
    export CLOUDFLARE_API_TOKEN
    while IFS= read -r line || [ -n "$line" ]; do
      name=''${line%%=*}
      case $name in
        AWS_ACCESS_KEY_ID | AWS_SECRET_ACCESS_KEY | NB_PAT | TF_VAR_state_passphrase) export "$name=''${line#*=}" ;;
      esac
    done < <(
      decrypt nix/tofu/secrets aws.age
      decrypt nix/tofu/secrets netbird-pat.age
      decrypt nix/tofu/secrets state-passphrase.age
    )

    exec tofu -chdir="$root/nix/tofu" "$@"
  '';
}
