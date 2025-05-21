{ config, pkgs, inputs, lib, ... }:

{
	programs.zsh.enable = true;
	users.users.emmathorpe = {
		isNormalUser = true;
		home = "/home/emmathorpe";
		description = "Emma Thorpe";
		extraGroups = [ "wheel" ];
		shell = pkgs.zsh;
		packages =  lib.mkIf (config.features.swayDesktop.enable == true) [
			pkgs.legcord
			#pkgs.plex-desktop
			#pkgs.plexamp
		];
	};
	programs.firefox = lib.mkIf(config.features.swayDesktop.enable == true) {
		enable = true;
	};
	programs.thunderbird = lib.mkIf(config.features.swayDesktop.enable == true) {
		enable = true;
	};
}
