{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  programs.zsh.enable = true;
  users.users.emmathorpe = {
    isNormalUser = true;
    home = "/home/emmathorpe";
    description = "Emma Thorpe";
    extraGroups = [
      "wheel"
      "docker"
    ];
    shell = pkgs.zsh;
  };
  programs.firefox = lib.mkIf (config.features.swayDesktop.enable == true) {
    enable = true;
  };
  programs.thunderbird = lib.mkIf (config.features.swayDesktop.enable == true) {
    enable = true;
  };
}
