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
			extraSessionCommands = ''
				# QT
        			export QT_QPA_PLATFORM="wayland;xcb"
        			export QT_QPA_PLATFORMTHEME=qt5ct
				# SDL
        			export SDL_VIDEODRIVER=wayland
				# Java
        			export _JAVA_AWT_WM_NONREPARENTING=1
				# Misc
        			export CLUTTER_BACKEND=wayland
        			export WINIT_UNIX_BACKEND=x11
        			export MOZ_ENABLE_WAYLAND=1
			'';
			extraPackages = with pkgs; [ brightnessctl foot grim swayidle swaylock i3status-rust sway-launcher-desktop dunst ];
		};
		fonts.packages = with pkgs; [
			noto-fonts
			noto-fonts-emoji
			font-awesome
		];
	};
	
}
