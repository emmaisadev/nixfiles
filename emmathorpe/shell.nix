{ config, lib, pkgs, ... }:

{
	#programs.zsh = {
	#	enable = true;
	#	ohMyZsh = {
	#		enable = true;
	#		plugins = [ "git" "man" "history-substring-search" ];
	#		theme = "robbyrussell";
	#	};
	#	syntaxHighlighting.enable = true;
	#	autosuggestions.enable = true;
	#};
	#programs.tmux = {
	#	enable = true;
	#	reverseSplit = true;
	#	terminal = "tmux-direct";
	#	newSession = true;
	#	keyMode = "vi";
	#	historyLimit = 50000;
	#	extraConfig = ''
	#		# Enable mouse support
	#		set -g mouse on
	#		# Set pane navigation
	#		bind -n M-Left select-pane -L
	#		bind -n M-Right select-pane -R
	#		bind -n M-Up select-pane -U
	#		bind -n M-Down select-pane -D
	#	'';
	#};
}
