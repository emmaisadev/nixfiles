{ config, pkgs, inputs, lib, ... }:

{
	programs.zsh = { 
		enable = true;
		enableCompletion = true;
		enableVteIntegration = true;
		autosuggestion.enable = true;
		historySubstringSearch.enable = true;
		history.append = true;
		oh-my-zsh = {
			enable = true;
			plugins = [ "git" "man" "history-substring-search" ];
			theme = "robbyrussell";
		};
		syntaxHighlighting.enable = true;
		initContent = lib.mkOrder 1500 ''
			if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
				exec sway
			fi
			if [ "$SSH_CLIENT" ] || [ "$SSH_TTY" ]; then
				export PS1=%M\ $PS1
			fi
		'';
		envExtra = ''
			alias cls=clear
		'';
	};
	programs.tmux = {
		enable = true;
		reverseSplit = true;
		terminal = "tmux-direct";
		newSession = true;
		keyMode = "vi";
    historyLimit = 50000;
    mouse = true;
		extraConfig = ''
			# Set pane navigation
			bind -n M-Left select-pane -L
			bind -n M-Right select-pane -R
			bind -n M-Up select-pane -U
			bind -n M-Down select-pane -D
		'';
	};
	home.stateVersion = "25.05";
	home.pointerCursor = {
	  gtk.enable = true;
	  x11 = {
		  enable = true;
		  defaultCursor = "Adwaita";
	  };
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
	};
	home.packages = [
    pkgs.element-desktop
    pkgs.commitizen
	];
	home.sessionVariables = {
		MOZ_USE_XINPUT2 = "1";
  	# only needed for Sway
  	XDG_CURRENT_DESKTOP = "sway"; 
	};
	programs.vim = {
		enable = true;
    defaultEditor = true;
    plugins = with pkgs.vimPlugins; [ nerdtree ale vim-fugitive vim-indent-guides ];
    settings = {
      expandtab = false;
      tabstop = 2;
      shiftwidth = 2;
    };
    extraConfig = ''
      let g:indent_guides_enable_on_vim_startup = 1
      if v:version < 802
        packadd! peaksea
      endif
      syntax enable
      colorscheme peaksea
      set termguicolors
      set background=dark
      au BufNewFile,BufRead *Jenkinsfile setf groovy
      '';
  };
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    settings = {
      user.name = "Emma Thorpe";
      push = {
        autoSetupRemote = true;
      };
      init = {
        defaultBranch = "main";
      };
    };
  };
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
}
