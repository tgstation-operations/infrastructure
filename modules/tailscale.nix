{
  pkgs,
  ...
}: {
  services.tailscale = {
    enable = true;
    openFirewall = true;
    extraUpFlags = [
      "--login-server=https://vpn.tgstation13.org"
    ];
    # override this to `server` for exit nodes
    useRoutingFeatures = "client";
  };

  # Bunch of workarounds here due to https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;

  systemd.services.tgstation-wait-online = {
    enable = true;
    description = "tgstation-NetworkManager-wait-online-replacement";
    requires = [ "NetworkManager.service" ];
    after = [ "NetworkManager.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.networkmanager}/bin/nm-online -q";
      Environment = "NM_ONLINE_TIMEOUT=60";
    };
    wantedBy = [ "network-online.target" ];
  };

  systemd.services.tailscaled = {
    environment = {
      "TS_DEBUG_FIREWALL_MODE" = "nftables";
      "IM_LITERALLY_JUST_SETTING_THIS_TO_RESTART_TAILSCALED_REMOVE_IT" = "chumbis";
    };
    after = ["systemd-networkd-wait-online.service" "tgstation-wait-online.service"];
    requires = [ "tgstation-wait-online.service" ];
  };

  systemd.services.tg-tailscale-wait-dhcp = {
    serviceConfig = {
      Type = "oneshot";
      # See https://github.com/tailscale/tailscale/issues/11504#issuecomment-2692132659
      ExecStart = "${pkgs.coreutils}/bin/timeout 60s ${pkgs.bash}/bin/bash -c \'until ${pkgs.tailscale}/bin/tailscale status --peers=false; do ${pkgs.coreutils}/bin/sleep 1; done\'";
    };
    wantedBy = [ "network-online.target" ];
    before = [ "network-online.target" ];
    after = [ "tailscaled.service" ];
    requires = [ "tailscaled.service" ];
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
      gawk
    ];
    script = ''
      ethtool -K $(ip -o route get 1.1.1.1 | gawk 'match($0, /dev (\w+) /, m) { print m[1] }') rx-udp-gro-forwarding on rx-gro-list off
    '';
  };
}
