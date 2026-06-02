{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    nixos-apple-silicon.url = "github:nix-community/nixos-apple-silicon";
    nixos-apple-silicon.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      nixos-wsl,
      nixos-apple-silicon,
      ...
    }:
    let
      # claude-code tracks nixpkgs-unstable regardless of the pinned nixpkgs.
      overlays = [
        (final: prev: {
          claude-code =
            (import nixpkgs-unstable {
              inherit (prev.stdenv.hostPlatform) system;
              config.allowUnfree = true;
            }).claude-code;
        })
      ];

      # Shared scaffolding for every host: common user, overlays, home-manager.
      mkHost =
        { system, extraModules }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./emmathorpe/user.nix
            {
              nixpkgs.overlays = overlays;
              nixpkgs.config.allowUnfree = true;
              nix.settings.experimental-features = [
                "nix-command"
                "flakes"
              ];
              # Make `nix shell nixpkgs#...` and <nixpkgs> use the pinned nixpkgs.
              nix.registry.nixpkgs.flake = nixpkgs;
              nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
            }
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ]
          ++ extraModules;
        };

      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    {
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      nixosConfigurations = {
        emmathorpe-mbp = mkHost {
          system = "aarch64-linux";
          extraModules = [
            ./system/machine/MBP-Asahi/configuration.nix
            nixos-apple-silicon.nixosModules.default
            ./emmathorpe/swaywm.nix
            { home-manager.users.emmathorpe = import ./emmathorpe/home.nix; }
          ];
        };

        emmathorpe-x1c = mkHost {
          system = "x86_64-linux";
          extraModules = [
            ./system/machine/X1/configuration.nix
            ./emmathorpe/swaywm.nix
            { home-manager.users.emmathorpe = import ./emmathorpe/home.nix; }
          ];
        };

        emmathorpe-edaas = mkHost {
          system = "x86_64-linux";
          extraModules = [
            ./system/machine/EDaaS/configuration.nix
            nixos-wsl.nixosModules.default
            ./emmathorpe/swaywm.nix
            {
              home-manager.users.emmathorpe.imports = [
                ./emmathorpe/home.nix
                ./system/modules/work/default.nix
              ];
            }
          ];
        };
      };
    };
}
