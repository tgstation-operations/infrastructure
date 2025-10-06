{
  config,
  pkgs,
  stdenv,
  ...
}: let
  ips-v4 = stdenv.mkDerivation {
    name = "cloudflare-ipv4-addresses";
    src = fetchurl {
      url = "https://www.cloudflare.com/ips-v4";
      hash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";
    };
  };
  ips-v6 = stdenv.mkDerivation {
    name = "cloudflare-ipv4-addresses";
    src = fetchurl {
      url = "https://www.cloudflare.com/ips-v6";
      hash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";
    };
  };
in {
  networking.firewall.allowedTCPPorts = [
    # These two are commented out on purpose, a custom firewall is used to only allow access to cloudflare IPs
    #80
    #443
  ];
  networking.firewall.extraInputRules = ''
    # Allow connections from cloudflare
    tcp dport { http, https } ip saddr {
      ${builtins.replaceStrings [ "\n" ] [",\n"] ips-v4 }
    } accept
    tcp dport { http, https } ip6 saddr {
      ${builtins.replaceStrings [ "\n" ] [",\n"] ips-v6 }
    } accept
  '';
}
