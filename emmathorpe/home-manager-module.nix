{config, pkgs, lib, ...}:

{
	home-manager.useGlobalPkgs = true;
	home-manager.useUserPackages = true;

lib.mkIf ( profile == "work" ) {
	home-manager.users.emmathorpe.imports = [ ./home.nix ../system/modules/work/default.nix ];
};
lib.mkIf ( profile == "home" ) {
	home-manager.users.emmathorpe.imports = [ ./home.nix ];
};
	
}
