# Graphical desktop layer: GUI apps, Wayland session env, cursor theme, and the
# tty1 Sway autostart. Imported only on hosts that run Sway (MBP, X1); never
# pulled onto the headless WSL host.
{ pkgs, lib, ... }:
{
  home.packages = [
    pkgs.element-desktop
    pkgs.legcord
    #pkgs.plex-desktop
    #pkgs.plexamp
  ];

  home.sessionVariables = {
    MOZ_USE_XINPUT2 = "1";
    XDG_CURRENT_DESKTOP = "sway";
  };

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

  # Start Sway automatically on the first virtual terminal.
  programs.zsh.initContent = lib.mkOrder 1500 ''
    if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
      exec sway
    fi
  '';
}
