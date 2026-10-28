{
  callPackage,
  opentofu,
}:
opentofu.withPlugins (p: [
  p.hashicorp_aws
  p.cloudflare_cloudflare
  (callPackage ../terraform-provider-netbird/package.nix {})
])
