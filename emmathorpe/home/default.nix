# Base home-manager profile, shared by every host (graphical or headless).
# Graphical hosts additionally import ./desktop.nix; the work host imports
# ../../system/modules/work/default.nix. See the host table in flake.nix.
{ ... }:
{
  imports = [
    ./shell.nix
    ./git.nix
    ./editor.nix
  ];

  home.stateVersion = "25.05";
}
