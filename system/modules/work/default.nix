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
}
