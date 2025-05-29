{
  description = "NixOS configuration";

  inputs = {
	nixpkgs.url = "nixpkgs/nixos-unstable";
	home-manager.url = "github:nix-community/home-manager";
	home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { self, nixpkgs, home-manager, ... }: {
    nixosConfigurations.emmathorpe-mbp = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";  
	    specialArgs = { inherit inputs; };
      modules = [
        ./system/machine/MBP-Asahi/configuration.nix
	      ./emmathorpe/user.nix
	      ./emmathorpe/swaywm.nix
	      home-manager.nixosModules.home-manager 
        {
		      home-manager.useGlobalPkgs = true;
		      home-manager.useUserPackages = true;
		      home-manager.users.emmathorpe = import ./emmathorpe/home.nix;
	      }
      ];
    };
    nixosConfigurations.emmathorpe-x1c = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";  
      specialArgs = { inherit inputs; };
      modules = [
        ./system/machine/X1/configuration.nix
	      ./emmathorpe/user.nix
	      ./emmathorpe/swaywm.nix
	      home-manager.nixosModules.home-manager
	      {
		      home-manager.useGlobalPkgs = true;
		      home-manager.useUserPackages = true;
		      home-manager.users.emmathorpe = import ./emmathorpe/home.nix;
	      }
      ];
    };
  };
}
