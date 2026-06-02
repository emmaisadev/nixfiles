{
  description = "NixOS configuration";

  inputs = {
    # Pinned stable channel; the single source of truth for every host.
    nixpkgs.url = "nixpkgs/nixos-26.05";
    # Bleeding-edge channel, used only to pull individual packages via overlay.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Home-manager release matched to the stable nixpkgs; `follows` keeps a single nixpkgs eval.
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # WSL module for the EDaaS host; flake input avoids the impure <nixos-wsl> NIX_PATH lookup.
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    # Apple Silicon (Asahi) support for the MacBook host.
    nixos-apple-silicon.url = "github:nix-community/nixos-apple-silicon";
    nixos-apple-silicon.inputs.nixpkgs.follows = "nixpkgs";
    # Provides mkFlake: the systems/perSystem scaffolding used below.
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

        # mkHost :: { system, modules } -> nixosSystem
        # Builds one machine by appending its host-specific modules to the shared
        # baseModules. `inputs` is threaded into specialArgs so any module can
        # reach the flake inputs (e.g. the work module uses inputs for claude-code).
        mkHost =
          { system, modules }:
          nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = { inherit inputs; };
            modules = baseModules ++ modules;
          };

        # Host table — declarative registry of every machine. To add a host:
        # give it a name, its `system`, and the list of machine-specific modules.
        # mapAttrs below turns each entry into a nixosConfiguration of the same name.
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

        # perSystem is evaluated once per entry in `systems`; `pkgs` is the
        # nixpkgs instance for that system. Outputs here become per-system
        # attrsets automatically (e.g. devShells.<system>.default).
        perSystem =
          { pkgs, ... }:
          {
            # `nix fmt` formatter for the repo.
            formatter = pkgs.nixfmt;

            # `nix develop` shell with the tooling needed to hack on this flake.
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

        # Realise the host table: each `hosts` entry becomes a nixosConfiguration.
        flake.nixosConfigurations = lib.mapAttrs (_name: mkHost) hosts;
      }
    );
}
