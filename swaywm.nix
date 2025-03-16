{ config, lib, options, pkgs, ... }:

let 
	cfg = config.features.swayDesktop;
in
{
	options = {
		features.swayDesktop.enable = lib.mkEnableOption "Enable Sway Desktop";
	};
	config = lib.mkIf cfg.enable {
		programs.sway = {
			enable = true;
			wrapperFeatures.gtk = true;
		};
		environment.systemPackages = with pkgs; [
			i3status-rust
			sway-launcher-desktop
		];
		fonts.packages = with pkgs; [
			noto-fonts
			noto-fonts-emoji
			font-awesome
		];
	};
	
}
