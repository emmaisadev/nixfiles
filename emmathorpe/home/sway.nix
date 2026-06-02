# Declarative Sway window manager, status bar, lock, idle and notifications.
# Imported via ./desktop.nix, so only graphical hosts get it.
#
# The compositor binary, PAM and polkit integration come from the system-level
# programs.sway (see ../swaywm.nix); package = null below reuses it instead of
# pulling a second Sway. home-manager owns the user config (~/.config/sway) and
# wires the systemd user session (sway-session.target), which is what lets the
# swayidle/dunst user services start with the desktop.
{ pkgs, lib, ... }:
{
  wayland.windowManager.sway = {
    enable = true;
    package = null;
    # `sway --validate` needs a real package; skip it since package = null.
    checkConfig = false;
    config = rec {
      modifier = "Mod4";
      terminal = "${pkgs.foot}/bin/foot";
      # Launcher: sway-launcher-desktop running inside a floating foot window.
      menu = "${pkgs.foot}/bin/foot --app-id=launcher ${pkgs.sway-launcher-desktop}/bin/sway-launcher-desktop";

      input."type:keyboard".xkb_layout = "dvorak";

      window.commands = [
        {
          criteria.app_id = "launcher";
          command = "floating enable, resize set 800 500";
        }
      ];

      bars = [
        {
          position = "top";
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-default.toml";
          fonts = {
            names = [
              "Noto Sans"
              "Font Awesome 6 Free"
            ];
            size = 11.0;
          };
        }
      ];

      keybindings = lib.mkOptionDefault {
        "${modifier}+l" = "exec ${pkgs.swaylock}/bin/swaylock -f";
        "Print" = "exec ${pkgs.grim}/bin/grim ~/screenshot-$(date +%F-%H%M%S).png";
        "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%+";
        "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
        "XF86AudioRaiseVolume" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioLowerVolume" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioMute" = "exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      };
    };
  };

  programs.swaylock = {
    enable = true;
    settings = {
      color = "1e1e2e";
      indicator-radius = 100;
      indicator-thickness = 7;
      show-failed-attempts = true;
    };
  };

  # Lock on idle, turn screens off shortly after, and lock before sleep.
  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 300;
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }
      {
        timeout = 600;
        command = "${pkgs.sway}/bin/swaymsg 'output * power off'";
        resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * power on'";
      }
    ];
    events = {
      before-sleep = "${pkgs.swaylock}/bin/swaylock -f";
      lock = "${pkgs.swaylock}/bin/swaylock -f";
    };
  };

  services.dunst = {
    enable = true;
    settings = {
      global = {
        font = "Noto Sans 11";
        frame_color = "#89b4fa";
        separator_color = "frame";
        offset = "10x10";
        corner_radius = 5;
      };
      urgency_critical = {
        frame_color = "#fab387";
        timeout = 0;
      };
    };
  };

  programs.i3status-rust = {
    enable = true;
    bars.default = {
      theme = "gruvbox-dark";
      icons = "awesome6";
      blocks = [
        {
          block = "disk_space";
          path = "/";
          format = " $icon $available ";
        }
        {
          block = "memory";
          format = " $icon $mem_used_percents ";
        }
        {
          block = "cpu";
          interval = 2;
        }
        { block = "sound"; }
        { block = "battery"; }
        {
          block = "time";
          interval = 5;
          format = " $timestamp.datetime(f:'%a %d/%m %R') ";
        }
      ];
    };
  };
}
