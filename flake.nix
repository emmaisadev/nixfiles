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
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      nixos-wsl,
      nixos-apple-silicon,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { lib, ... }:
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

        # Unfree packages permitted to be built (replaces blanket allowUnfree).
        unfreePackages = [
          "claude-code"
          "lens"
          "lens-desktop"
        ];

        # Shared scaffolding for every host: common user, overlays, home-manager.
        baseModules = [
          ./emmathorpe/user.nix
          {
            nixpkgs.overlays = overlays;
            nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) unfreePackages;
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
        ];

        mkHost =
          { system, modules }:
          nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = { inherit inputs; };
            modules = baseModules ++ modules;
          };

        # Host table — add new machines here.
        hosts = {
          emmathorpe-mbp = {
            system = "aarch64-linux";
            modules = [
              ./system/machine/MBP-Asahi/configuration.nix
              nixos-apple-silicon.nixosModules.default
              ./emmathorpe/swaywm.nix
              { home-manager.users.emmathorpe = import ./emmathorpe/home.nix; }
            ];
          };

          emmathorpe-x1c = {
            system = "x86_64-linux";
            modules = [
              ./system/machine/X1/configuration.nix
              ./emmathorpe/swaywm.nix
              { home-manager.users.emmathorpe = import ./emmathorpe/home.nix; }
            ];
          };

          emmathorpe-edaas = {
            system = "x86_64-linux";
            modules = [
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
      in
      {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];

        perSystem =
          { pkgs, ... }:
          {
            formatter = pkgs.nixfmt;

            devShells.default = pkgs.mkShellNoCC {
              packages = with pkgs; [
                nixfmt
                nil
                git
              ];
            };

            checks.formatting =
              pkgs.runCommandLocal "check-formatting" { nativeBuildInputs = [ pkgs.nixfmt ]; }
                ''
                  # Generated hardware-configuration.nix files are excluded.
                  nixfmt --check $(find ${./.} -name '*.nix' -not -name 'hardware-configuration.nix') && touch $out
                '';
          };

        flake.nixosConfigurations = lib.mapAttrs (_name: mkHost) hosts;
      }
    );
}
