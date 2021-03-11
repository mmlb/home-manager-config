{ config, lib, pkgs, ... }:
let mod = config.wayland.windowManager.sway.config.modifier;
in {
  wayland.windowManager.sway = {
    enable = true;
    config = {
      assigns."17:meld" = [{ app_id = "org.gnome.meld"; }];
      bars = [ ];
      colors = {
        focused = {
          border = "#2f343f";
          background = "#2f343f";
          childBorder = "#285577";
          indicator = "#2e9ef4";
          text = "#f3f4f5";
        };
        focusedInactive = {
          border = "#2f343f";
          background = "#2f343f";
          childBorder = "#5f676a";
          indicator = "#464e50";
          text = "#676e7d";
        };
        unfocused = {
          border = "#2f343f";
          background = "#2f343f";
          childBorder = "#222222";
          indicator = "#292d2e";
          text = "#676e7d";
        };
        urgent = {
          border = "#e53935";
          background = "#e53935";
          childBorder = "#900000";
          indicator = "#900000";
          text = "#f3f4f5";
        };
      };
      fonts = [ "Iosevka 12" ];
      input = {
        "DELL08AF:00 06CB:76AF Touchpad" = {
          tap = "enabled";
          click_method = "clickfinger";
          drag = "enabled";
          tap_button_map = "lrm";
        };
        "type:pointer" = {
          scroll_method = "on_button_down";
          scroll_button = "278";
        };
      };
      keybindings = lib.mkOptionDefault {
        # own creation
        "${mod}+a" = "workspace 10:a";
        "${mod}+b" = "workspace 11:b";
        "${mod}+c" = "workspace 12:c";
        "${mod}+d" = "workspace 13:d";
        "${mod}+e" = "workspace 14:e";
        "${mod}+f" = "workspace 15:f";
        "${mod}+Shift+a" = "move container to workspace 10:a";
        "${mod}+Shift+b" = "move container to workspace 11:b";
        "${mod}+Shift+c" = "move container to workspace 12:c";
        "${mod}+Shift+d" = "move container to workspace 13:d";
        "${mod}+Shift+e" = "move container to workspace 14:e";
        "${mod}+Shift+f" = "move container to workspace 15:f";

        "${mod}+m" = "workspace 16:meld";
        "${mod}+w" = "workspace 17:work";
        "${mod}+z" = "workspace 18:zoom";
        "${mod}+Shift+m" = "move container to workspace 16:meld";
        "${mod}+Shift+w" = "move container to workspace 17:work";
        "${mod}+Shift+z" = "move container to workspace 18:zoom";

        "${mod}+Tab" = "workspace back_and_forth";
        "${mod}+q" = "exec ~/bin/focus-last.py --switch";

        "XF86AudioLowerVolume" =
          "exec --no-startup-id pactl set-sink-volume 0 -5%";
        "XF86AudioMute" = "exec --no-startup-id pactl set-sink-volume 0 toggle";
        "XF86AudioNext" = "exec --no-startup-id playerctl next";
        "XF86AudioPause" = "exec --no-startup-id playerctl pause";
        "XF86AudioPlay" = "exec --no-startup-id playerctl play";
        "XF86AudioPrev" = "exec --no-startup-id playerctl previous";
        "XF86AudioRaiseVolume" =
          "exec --no-startup-id pactl set-sink-volume 0 +5%";

        "XF86MonBrightnessUp" =
          "exec --no-startup-id light -A 10 -s sysfs/backligh/intel_backlight";
        "XF86MonBrightnessDown" =
          "exec --no-startup-id light -U 10 -s sysfs/backligh/intel_backlight";

        # changed from defaults
        "${mod}+n" = "splith";
        "${mod}+p" = "focus parent";
        "${mod}+r" =
          "exec --no-startup-id ${config.wayland.windowManager.sway.config.menu}";
        "${mod}+t" = "layout toggle split";

        "${mod}+Control+e" = "exit";
        "${mod}+Control+r" = "mode resize";

        "${mod}+Shift+r" = "reload";
      };
      menu = "${pkgs.wofi}/bin/wofi --show run | xargs swaymsg exec --";
      modifier = "Mod4";
      output = {
        DP-2 = {
          position = "0,0";
          scale = "2";
        };
        eDP-1 = {
          position = "0,1080";
          scale = "2";
        };
      };
      startup = [
        {
          command = ''
            swayidle timeout 1200 'swaylock -c 000000' timeout 1500 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' before-sleep 'swayloc -c 000000' '';
        }
        {
          command =
            "waybar -c ~/.config/waybar/config -s ~/.config/waybar/style.css";
        }
        { command = "systemctl --user import-environment"; }
      ];
      terminal = "${pkgs.kitty}/bin/kitty";
      window.commands = [{
        command = "floating toggle, move scratchpad";
        criteria = { title = "Firefox [-—] Sharing Indicator"; };
      }];
      workspaceAutoBackAndForth = true;
    };
    wrapperFeatures.gtk = true;
    xwayland = true;
  };
}
