{
  description = "System configurations";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://attic.tgstation13.org/tgstation-infrastructure"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "tgstation-infrastructure:07mCKRLs4Y+ietmQ5A1Wn3hRYHVUu1vZ20xPmwMyrBA="
    ];
  };
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixpkgs-headscale.url = "github:nixos/nixpkgs/9807714d6944a957c2e036f84b0ff8caf9930bc0";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dragon-bot.url = "github:tgstation/dragon-bot";
    oidc-reverse-proxy = {
      url = "github:Cyberboss/oidc-reverse-proxy";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tg-public-log-parser = {
      url = "github:tgstation/tg-public-log-parser";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tgstation-website = {
      url = "github:tgstation-operations/website-v2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tgstation-phpbb = {
      url = "github:tgstation-operations/tgstation-phpbb";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    server-info-fetcher = {
      url = "github:tgstation-operations/server-info-fetcher";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    colmena = {
      url = "github:zhaofengli/colmena/5fdd743a11e7291bd8ac1e169d62ba6156c99be4";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      # TGS builds the games' Rust libraries with this toolchain on every
      # deploy, and Rust 1.100 cannot build dreamluau 0.1.2, which they pin.
      url = "github:nix-community/fenix?rev=eee23db5a2c4a6d3d4ed117370f5f490da65b665";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    authentik-nix = {
      url = "github:nix-community/authentik-nix?rev=48ddf622759f590470b69374fd999f08de96d190";
      # add this follows back when we bump nixpkgs
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    # lix-module = {
    #   url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.2-1.tar.gz";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    colmena,
    fenix,
    ...
  }: let
    flakeModules = [
      inputs.agenix.nixosModules.default
      inputs.disko.nixosModules.default
      # inputs.lix-module.nixosModules.default
      (import ./modules/colmena_ci.nix)
      (import ./nix/modules/haproxy)
    ];

    colmenaPackages = import nixpkgs {
      system = "x86_64-linux";
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };
      overlays = [fenix.overlays.default];
    };

    tg-globals = {
      tgs = {
        port = "5000";
        root-path = "/persist/tgs-data";
        instances-path = "${tg-globals.tgs.root-path}/instances";
      };
      caddy = {
        default-package =
          (import nixpkgs-unstable {
            system = "x86_64-linux";
            config.allowUnfree = true;
          })
          .caddy;
      };
      netbird = {
        domain = "netbird.tgstation13.org";
        dns-domain = "tg.internal";
      };
    };

    tgsatan = {
      deployment = {
        targetHost = "tgsatan.tg.internal";
        targetUser = "deploy";
      };
      imports =
        flakeModules
        ++ [
          inputs.impermanence.nixosModules.impermanence
          (import ./modules/base.nix)
          (import ./modules/users)
          (import ./systems/game-servers/systems/tgsatan)
        ];
    };

    vpn = {
      deployment = {
        targetHost = "vpn.tgstation13.org";
        targetUser = "deploy";
      };
      imports =
        flakeModules
        ++ [
          (import ./modules/base.nix)
          (import ./modules/users)
          (import ./systems/vpn)
        ];
    };

    dallas = {
      deployment = {
        targetHost = "dallas.tg.internal";
        targetUser = "deploy";
        tags = [
          "relay-amd64"
        ];
      };
      imports =
        flakeModules
        ++ [
          (import ./modules/base.nix)
          (import ./modules/users)
          (import ./systems/edge-nodes/systems/us-dallas.nix)
        ];
    };

    chicago = {
      deployment = {
        targetHost = "chicago.tg.internal";
        targetUser = "deploy";
        tags = [
          "relay-amd64"
        ];
      };
      imports =
        flakeModules
        ++ [
          (import ./modules/base.nix)
          (import ./modules/users)
          (import ./systems/edge-nodes/systems/us-chicago.nix)
        ];
    };

    atlanta = {
      deployment = {
        targetHost = "atlanta.tg.internal";
        targetUser = "deploy";
        tags = [
          "relay-amd64"
        ];
      };
      imports =
        flakeModules
        ++ [
          (import ./modules/base.nix)
          (import ./modules/users)
          (import ./systems/edge-nodes/systems/us-atlanta.nix)
        ];
    };

    blockmoths = {
      deployment = {
        targetHost = "blockmoths.tg.internal";
        targetUser = "deploy";
      };
      imports =
        flakeModules
        ++ [
          inputs.impermanence.nixosModules.impermanence
          (import ./modules/base.nix)
          (import ./modules/users)
          (import ./systems/game-servers/systems/blockmoths)
        ];
    };
    wiggle = {
      deployment = {
        targetHost = "wiggle.tg.internal";
        targetUser = "deploy";
        tags = [
          "staging"
        ];
      };
      imports =
        flakeModules
        ++ [
          (import ./modules/base.nix)
          (import ./modules/users)
          (import ./systems/game-servers/systems/staging)
        ];
    };
    warsaw = {
      deployment = {
        targetHost = "warsaw.tg.internal";
        targetUser = "deploy";
        tags = [
          "staging"
        ];
      };
      imports =
        flakeModules
        ++ [
          (import ./modules/base.nix)
          (import ./modules/users)
          (import ./systems/edge-nodes/systems/staging)
        ];
    };
    lemon = {
      deployment = {
        targetHost = "lemon.tg.internal";
        targetUser = "deploy";
        tags = [
          "relay-amd64"
        ];
      };
      imports =
        flakeModules
        ++ [
          (import ./modules/base.nix)
          (import ./modules/users)
          (import ./systems/edge-nodes/systems/lemon)
        ];
    };
    bratwurst = {
      deployment = {
        targetHost = "bratwurst.tg.internal";
        targetUser = "deploy";
        tags = [
          "relay-arm"
        ];
      };
      nixpkgs.system = "aarch64-linux";
      imports =
        flakeModules
        ++ [
          (import ./modules/base.nix)
          (import ./modules/users)
          (import ./systems/edge-nodes/systems/eu-bratwurst.nix)
        ];
    };
    dachshund = {
      deployment = {
        targetHost = "dachshund.tg.internal";
        targetUser = "deploy";
        tags = [
          "relay-arm"
        ];
      };
      nixpkgs.system = "aarch64-linux";
      imports =
        flakeModules
        ++ [
          (import ./modules/base.nix)
          (import ./modules/users)
          (import ./systems/edge-nodes/systems/eu-dachshund.nix)
        ];
    };
    knipp = {
      deployment = {
        targetHost = "knipp.tg.internal";
        targetUser = "deploy";
        tags = [
          "relay-arm"
        ];
      };
      nixpkgs.system = "aarch64-linux";
      imports =
        flakeModules
        ++ [
          (import ./modules/base.nix)
          (import ./modules/users)
          (import ./systems/edge-nodes/systems/eu-knipp.nix)
        ];
    };

    perSystem = nixpkgs.lib.genAttrs ["x86_64-linux" "aarch64-linux"] (system:
      import ./nix/per-system.nix {
        inherit inputs;
        pkgs = nixpkgs.legacyPackages.${system};
      });
  in {
    colmenaHive = assert nixpkgs.lib.assertMsg (colmenaPackages.colmena.src.outPath == colmena.outPath)
    "nixpkgs' colmena deploys the hive the colmena input builds, so the input must be at its source.";
      colmena.lib.makeHive self.outputs.colmena;
    colmena = {
      inherit
        tgsatan
        dallas
        vpn
        chicago
        atlanta
        blockmoths
        wiggle
        warsaw
        lemon
        bratwurst
        dachshund
        knipp
        ;

      meta = {
        nixpkgs = colmenaPackages;
        specialArgs = {
          inherit
            self
            inputs
            nixpkgs
            fenix
            tg-globals
            ;
          pkgs-unstable = import nixpkgs-unstable {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        };
        nodeSpecialArgs = {
          tgsatan = {
            headscaleIPv4 = "100.64.0.1";
          };
          wiggle = {
            headscaleIPv4 = "100.64.0.25";
          };
          blockmoths = {
            headscaleIPv4 = "100.64.0.11";
          };
          bratwurst = {
            pkgs-unstable = import nixpkgs-unstable {
              system = "aarch64-linux";
              config.allowUnfree = true;
            };
          };
          dachshund = {
            pkgs-unstable = import nixpkgs-unstable {
              system = "aarch64-linux";
              config.allowUnfree = true;
            };
          };
          knipp = {
            pkgs-unstable = import nixpkgs-unstable {
              system = "aarch64-linux";
              config.allowUnfree = true;
            };
          };
        };
      };
    };
    nixosConfigurations = self.colmenaHive.nodes;

    packages = builtins.mapAttrs (_: s: s.packages) perSystem;
    devShells = builtins.mapAttrs (_: s: {default = s.devShell;}) perSystem;
    checks = builtins.mapAttrs (_: s: s.checks) perSystem;

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
    formatter.x86_64-darwin = nixpkgs.legacyPackages.x86_64-darwin.alejandra;
    formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.alejandra;
    formatter.aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.alejandra;
  };
}
