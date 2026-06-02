{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  programs.git = {
    settings = {
      commit.gpgsign = true;
      tag.gpgsign = true;
      gpg.format = "ssh";
      user.signingkey = "~/.ssh/id_ed25519.pub";
      user.email = "emma.thorpe@citrix.com";
    };
  };
  home.packages = [
    pkgs.kubectl
    pkgs.argo-rollouts
    pkgs.tenv
    pkgs.kubernetes-helm
    pkgs.azure-cli
    pkgs.kubelogin
    pkgs.curl
    pkgs.notation
    pkgs.powershell
    pkgs.nuget
    pkgs.gedit
    pkgs.lens
    pkgs.python3
    pkgs.gnumake
    pkgs.gcc
    pkgs.libiconv
    pkgs.autoconf
    pkgs.automake
    pkgs.pkg-config
    pkgs.wget
    pkgs.claude-code
    pkgs.google-cloud-sdk
  ];
  home.shellAliases = {
    docker = "/run/current-system/sw/bin/docker";
  };
  programs.tmux = {
    extraConfig = ''
      			set -g status-right "#(/run/current-system/sw/bin/bash $HOME/code/kube-tmux/kube.tmux 250 red black)"		
    '';
  };
  programs.go = {
    enable = true;
  };
}
