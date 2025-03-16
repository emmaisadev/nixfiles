{ config, lib, pkgs, ... }:

{
	programs.zsh = {
		enable = true;
		ohMyZsh = {
			enable = true;
			plugins = [ "git" "man" "history-substring-search" ];
			theme = "robbyrussell";
		};
		syntaxHighlighting.enable = true;
		autosuggestions.enable = true;
	};
}
