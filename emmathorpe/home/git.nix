# Version control: git + delta pager + commitizen. The work host layers
# commit signing and an email override on top (see work/default.nix).
{ pkgs, ... }:
{
  home.packages = [
    pkgs.commitizen
  ];

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
