{ config, pkgs, inputs, lib, ... }:

{
  programs.git = {
    userEmail = "emma.thorpe@cloud.com";
  };
  home.packages = [
	pkgs.kubectl
	pkgs.tenv
	pkgs.kubernetes-helm
	pkgs.azure-cli
	pkgs.kubelogin
	pkgs.curl
  ];
	programs.tmux = {
		extraConfig = ''
			set -g status-right "#(/run/current-system/sw/bin/bash $HOME/code/kube-tmux/kube.tmux 250 red black)"		
'';
	};
}
