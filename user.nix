{ config, pkgs, lib, ... }:

{
	users.users.emmathorpe = {
		isNormalUser = true;
		home = "/home/emmathorpe";
		description = "Emma Thorpe";
		extraGroups = [ "wheel" ];
		shell = pkgs.zsh;
		packages =  lib.mkIf (config.features.swayDesktop.enable == true) [
			pkgs.discord
		];
	};
	programs.firefox = lib.mkIf(config.features.swayDesktop.enable == true) {
		enable = true;
	};

}
