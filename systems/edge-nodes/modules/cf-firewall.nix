{
  config,
  pkgs,
  ...
}: let
  ips-v4 = builtins.fetchurl {
    url = "https://www.cloudflare.com/ips-v4";
    sha256 = "sha256:0ywy9sg7spafi3gm9q5wb59lbiq0swvf0q3iazl0maq1pj1nsb7h";
  };
  ips-v6 = builtins.fetchurl {
    url = "https://www.cloudflare.com/ips-v6";
    sha256 = "sha256:1ad09hijignj6zlqvdjxv7rjj8567z357zfavv201b9vx3ikk7cy";
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
