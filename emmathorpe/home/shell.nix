# Interactive shell: zsh + tmux. Wanted on every host.
{ lib, ... }:
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
      plugins = [
        "git"
        "man"
        "history-substring-search"
      ];
      theme = "robbyrussell";
    };
    syntaxHighlighting.enable = true;
    # Prefix the prompt with the hostname over SSH. The graphical autostart
    # (exec sway on tty1) lives in ./desktop.nix so it never runs on headless
    # hosts.
    initContent = lib.mkOrder 1500 ''
      if [ "$SSH_CLIENT" ] || [ "$SSH_TTY" ]; then
        export PS1="%M $PS1"
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
      # Alt+Arrow pane navigation
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D
    '';
  };
}
