{
  config,
  pkgs,
  lib,
  ...
}: {
  hardware.nvidia = {
    # We use lib.mkOverride 500 here to ensure it doesn't go under any upstream hardware modules using lib.mkDefault, but will be overriden by host modules
    # recommended for RTX and later cards
    open = lib.mkOverride 500 true;

    # By default, assume no iGPU. Should be turned on per node as needed
    prime.sync.enable = lib.mkOverride 500 false;
    prime.reverseSync.enable = lib.mkOverride 500 false;
    prime.offload.enable = lib.mkOverride 500 false;
  };
}
