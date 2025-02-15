{
  description = "System configurations";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://alejandra.cachix.org"
      "https://attic.tgstation13.org/tgstation-infrastructure"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "alejandra.cachix.org-1:NjZ8kI0mf4HCq8yPnBfiTurb96zp1TBWl8EC54Pzjm0="
      "tgstation-infrastructure:tNpjd5GxK1xymRHsJdBLTpeDScA2mVPdKA/eIOLOE0I="
    ];
  };
  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    alejandra = {
      url = "github:kamadorueda/alejandra/3.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable-small";
    dragon-bot.url = "github:tgstation/dragon-bot";
    tgstation-server.url = "github:tgstation/tgstation-server?dir=build/package/nix";
    tgstation-website.url = "github:tgstation-operations/website-v2";
    impermanence.url = "github:scriptis/impermanence";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    colmena.url = "github:zhaofengli/colmena";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    colmena,
    alejandra,
    fenix,
    ...
  }: let
    flakeModules = [
      inputs.home-manager.nixosModules.home-manager
      inputs.agenix.nixosModules.default
      inputs.disko.nixosModules.default
      (import ./modules/colmena_ci.nix)
    ];

    colmenaPackages = import nixpkgs {
      system = "x86_64-linux";
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };
      overlays = [];
    };

    tgsatan = {
      deployment = {
        targetHost = "tgsatan.tg.lan";
        targetUser = "deploy";
      };
      imports =
        flakeModules
        ++ [
          inputs.impermanence.nixosModules.impermanence
          (import ./modules/base.nix)
          (import ./users)
          (import ./nixos_systems/tgsatan)
        ];
    };

    vpn = {
      deployment = {
        targetHost = "vpn.tg.lan";
        targetUser = "deploy";
      };
      imports =
        flakeModules
        ++ [
          (import ./modules/base.nix)
          (import ./users)
          (import ./nixos_systems/vpn.nix)
        ];
    };

    dallas = {
      deployment = {
        targetHost = "dallas.tg.lan";
        targetUser = "deploy";
        tags = [
          "relay"
        ];
      };
      imports =
        flakeModules
        ++ [
          (import ./modules/base.nix)
          (import ./users)
          (import ./nixos_systems/relay-node/us/dallas.nix)
        ];
    };

    chicago = {
      deployment = {
        targetHost = "chicago.tg.lan";
        targetUser = "deploy";
        tags = [
          "relay-amd64"
        ];
      };
      imports =
        flakeModules
        ++ [
          (import ./modules/base.nix)
          (import ./users)
          (import ./nixos_systems/relay-node/us/chicago.nix)
        ];
    };

    atlanta = {
      deployment = {
        targetHost = "atlanta.tg.lan";
        targetUser = "deploy";
        tags = [
          "relay-amd64"
        ];
      };
      imports =
        flakeModules
        ++ [
          (import ./modules/base.nix)
          (import ./users)
          (import ./nixos_systems/relay-node/us/atlanta.nix)
        ];
    };

    blockmoths = {
      deployment = {
        targetHost = "blockmoths.tg.lan";
        targetUser = "deploy";
      };
      imports =
        flakeModules
        ++ [
          inputs.impermanence.nixosModules.impermanence
          (import ./modules/base.nix)
          (import ./users)
          (import ./nixos_systems/blockmoths)
        ];
    };
    wiggle = {
      deployment = {
        targetHost = "wiggle.tg.lan";
        targetUser = "deploy";
        tags = [
          "staging"
        ];
      };
      imports =
        flakeModules
        ++ [
          (import ./modules/base.nix)
          (import ./users)
          (import ./nixos_systems/staging/wiggle)
        ];
    };
    warsaw = {
      deployment = {
        targetHost = "warsaw.tg.lan";
        targetUser = "deploy";
        tags = [
          "staging"
        ];
      };
      imports =
        flakeModules
        ++ [
          (import ./modules/base.nix)
          (import ./users)
          (import ./nixos_systems/relay-node/staging/warsaw.nix)
        ];
    };
    lime = {
      deployment = {
        targetHost = "lime.tg.lan";
        targetUser = "deploy";
        tags = [
          "relay-amd64"
        ];
      };
      imports =
        flakeModules
        ++ [
          (import ./modules/base.nix)
          (import ./users)
          (import ./nixos_systems/relay-node/us/lime.nix)
        ];
    };
    bratwurst = {
      deployment = {
        targetHost = "bratwurst.tg.lan";
        targetUser = "deploy";
        tags = [
          "relay"
        ];
      };
      nixpkgs.system = "aarch64-linux";
      imports =
        flakeModules
        ++ [
          (import ./modules/base.nix)
          (import ./users)
          (import ./nixos_systems/relay-node/eu/bratwurst.nix)
        ];
    };
    dachshund = {
      deployment = {
        targetHost = "dachshund.tg.lan";
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
          (import ./users)
          (import ./nixos_systems/relay-node/eu/dachshund.nix)
        ];
    };
    knipp = {
      deployment = {
        targetHost = "knipp.tg.lan";
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
          (import ./users)
          (import ./nixos_systems/relay-node/eu/knipp.nix)
        ];
    };
  in {
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
        lime
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
    nixosConfigurations = {
      tgsatan = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = flakeModules ++ tgsatan.imports;
        specialArgs = {
          inherit self inputs nixpkgs fenix;
          pkgs-unstable = import nixpkgs-unstable {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          headscaleIPv4 = "100.64.0.1";
        };
      };
      blockmoths = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = flakeModules ++ blockmoths.imports;
        specialArgs = {
          inherit self inputs nixpkgs fenix;
          pkgs-unstable = import nixpkgs-unstable {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          headscaleIPv4 = "100.64.0.11";
        };
      };
      wiggle = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = flakeModules ++ wiggle.imports;
        specialArgs = {
          inherit self inputs nixpkgs fenix;
          pkgs-unstable = import nixpkgs-unstable {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          headscaleIPv4 = "100.64.0.25";
        };
      };
      vpn = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = flakeModules ++ vpn.imports;
        specialArgs = {
          inherit self inputs nixpkgs fenix;
          pkgs-unstable = import nixpkgs-unstable {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        };
      };
      dallas = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = flakeModules ++ dallas.imports;
        specialArgs = {
          inherit self inputs nixpkgs fenix;
          pkgs-unstable = import nixpkgs-unstable {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        };
      };
      chicago = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = flakeModules ++ chicago.imports;
        specialArgs = {
          inherit self inputs nixpkgs fenix;
          pkgs-unstable = import nixpkgs-unstable {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        };
      };
      atlanta = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = flakeModules ++ atlanta.imports;
        specialArgs = {
          inherit self inputs nixpkgs fenix;
          pkgs-unstable = import nixpkgs-unstable {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        };
      };
      warsaw = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = flakeModules ++ warsaw.imports;
        specialArgs = {
          inherit self inputs nixpkgs fenix;
          pkgs-unstable = import nixpkgs-unstable {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        };
      };
      lime = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = flakeModules ++ lime.imports;
        specialArgs = {
          inherit self inputs nixpkgs fenix;
          pkgs-unstable = import nixpkgs-unstable {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        };
      };
      bratwurst = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = flakeModules ++ bratwurst.imports;
        specialArgs = {
          inherit self inputs nixpkgs fenix;
          pkgs-unstable = import nixpkgs-unstable {
            system = "aarch64-linux";
            config.allowUnfree = true;
          };
        };
      };
      dachshund = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = flakeModules ++ dachshund.imports;
        specialArgs = {
          inherit self inputs nixpkgs fenix;
          pkgs-unstable = import nixpkgs-unstable {
            system = "aarch64-linux";
            config.allowUnfree = true;
          };
        };
      };
      knipp = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = flakeModules ++ knipp.imports;
        specialArgs = {
          inherit self inputs nixpkgs fenix;
          pkgs-unstable = import nixpkgs-unstable {
            system = "aarch64-linux";
            config.allowUnfree = true;
          };
        };
      };
    };

    formatter.x86_64-linux = alejandra.defaultPackage.x86_64-linux;
    formatter.x86_64-darwin = alejandra.defaultPackage.x86_64-darwin;
    formatter.aarch64-darwin = alejandra.defaultPackage.aarch64-darwin;
    formatter.aarch64-linux = alejandra.defaultPackage.aarch64-linux;
  };
}
