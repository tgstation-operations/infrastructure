{
  config,
  lib,
  pkgs,
  ...
}: let
  tofu = pkgs.callPackage ../../../nix/packages/opentofu/package.nix {};
  configuration = builtins.path {
    name = "tofu-configuration";
    path = ../../../nix/tofu;
    filter = path: _: lib.hasSuffix ".tf" path;
  };
  secret = name: config.age.secrets.${name}.path;

  # tofu writes its lock file and providers beside the configuration, so it
  # runs on a copy of it.
  run = name: command: {
    description = "OpenTofu ${name} of nix/tofu";
    wants = ["network-online.target"];
    after = ["network-online.target" "netbird-management.service"];
    path = [tofu];
    environment.HOME = "/var/lib/tofu";
    serviceConfig = {
      Type = "oneshot";
      DynamicUser = true;
      StateDirectory = "tofu";
      EnvironmentFile = [(secret "tofu-aws") (secret "tofu-netbird-pat") (secret "tofu-state-passphrase")];
      LoadCredential = ["cloudflare:${secret "cloudflare-api"}"];
      CapabilityBoundingSet = "";
      LockPersonality = true;
      PrivateDevices = true;
      ProtectHome = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX"];
      SystemCallArchitectures = "native";
    };
    script = ''
      CLOUDFLARE_API_TOKEN=$(<"$CREDENTIALS_DIRECTORY/cloudflare")
      export CLOUDFLARE_API_TOKEN
      rm -rf "$STATE_DIRECTORY/configuration"
      cp -r --no-preserve=mode ${configuration} "$STATE_DIRECTORY/configuration"
      cd "$STATE_DIRECTORY/configuration"
      tofu init -input=false -no-color
      ${command}
    '';
  };
in {
  age.secrets = {
    tofu-aws.file = ../../../nix/tofu/secrets/aws.age;
    tofu-netbird-pat.file = ../../../nix/tofu/secrets/netbird-pat.age;
    tofu-state-passphrase.file = ../../../nix/tofu/secrets/state-passphrase.age;
  };

  # A deploy that changes the configuration changes this unit, and a switch
  # restarts it, which applies it. RemainAfterExit keeps it active, or the
  # switch would leave a changed, finished unit alone.
  systemd.services.tofu-apply = lib.recursiveUpdate (run "apply" "tofu apply -input=false -no-color -auto-approve") {
    wantedBy = ["multi-user.target"];
    serviceConfig.RemainAfterExit = true;
  };

  # Fails when what is live has drifted from the configuration, such as an
  # edit in a dashboard; exit status 2 is a plan with changes.
  systemd.services.tofu-drift = run "drift check" "tofu plan -input=false -no-color -detailed-exitcode -lock=false";
  systemd.timers.tofu-drift = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "daily";
      RandomizedDelaySec = "1h";
      Persistent = true;
    };
  };
}
