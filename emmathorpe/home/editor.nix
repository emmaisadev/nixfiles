# Editor: vim as the default $EDITOR. Wanted on every host.
{ pkgs, ... }:
{
  programs.vim = {
    enable = true;
    defaultEditor = true;
    plugins = with pkgs.vimPlugins; [
      nerdtree
      ale
      vim-fugitive
      vim-indent-guides
    ];
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
}
