{pkgs, ...}: {
  services.tailscale = {
    enable = true;
    openFirewall = true;
    extraUpFlags = [
      "--login-server=https://vpn.tgstation13.org"
    ];
    # override this to `server` for exit nodes
    useRoutingFeatures = "client";
  };

  systemd.services.tailscaled.environment = {
    "TS_DEBUG_FIREWALL_MODE" = "nftables";
  };

  networking.firewall.trustedInterfaces = ["tailscale0"];
  networking.firewall.rejectPackets = true;
  # networking.firewall.checkReversePath = lib.mkForce true;
  networking.firewall.filterForward = true;
  networking.firewall.extraForwardRules = ''
    iifname "tailscale0*" accept # Accept all packets from tailscale
  '';
  networking.firewall.extraReversePathFilterRules = ''
    iifname "tailscale0*" accept # Allow packets originating from tailscale to ignore reverse path filtering
  '';

  systemd.services.optimize-tailscale = {
    enable = true;
    description = "fixup UDP GRO rules for tailscale";
    before = ["tailscale.service"];
    wantedBy = ["multi-user.target"];
    path = with pkgs; [
      ethtool
      iproute2
      coreutils
    ];
    script = ''
      ethtool -K $(ip -o route get 1.1.1.1 | gawk 'match($0, /dev (\w+) /, m) { print m[1] }') rx-udp-gro-forwarding on rx-gro-list off
    '';
  };
}
