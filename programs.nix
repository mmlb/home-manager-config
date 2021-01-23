{ pkgs, ... }: {

  programs = {
    direnv = {
      enable = true;
      enableFishIntegration = false;
      stdlib = ''
        use_nix() {
                eval "$(lorri direnv)"
        }
      '';
    };
    fzf.enable = true;
    git = {
      enable = true;
      aliases = {
        hub = "!${pkgs.gitAndTools.hub}/bin/hub";
        lg =
          "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        log1 = "log --oneline";
        log1m = "log --oneline master..";
        log1r = "log --oneline --reverse";
        log1rm = "log --oneline --reverse master..";
        mt = "!mergetool";
      };
      delta = {
        enable = false;
        options = { };
      };
      extraConfig = {
        advice.implicitIdentity = false;
        branch.autoSetupRebase = "always";
        checkout.defaultRemote = "origin";
        color.ui = true;
        commit.verbose = true;
        core.pager = "delta --diff-so-fancy";
        diff = {
          renameLimit = 2048;
          algorithm = "histogram";
          renames = "copies";
          submodule = "log";
        };
        difftool.prompt = "no";
        help.autoCorrect = 1;
        interactive.diffFilter = "delta --diff-so-fancy --color-only";
        log.date = "auto:human";
        merge = {
          log = true;
          tool = "meld";
          renameLimit = 2048;
        };
        mergetool = {
          keepBackup = false;
          prompt = "no";
        };
        pager = {
          diff = "delta --diff-so-fancy";
          show = "delta --diff-so-fancy";
        };
        push = {
          default = "current";
          followTags = true;
        };
        rebase = {
          autoSquash = true;
          stat = true;
        };
        submodule.fetchJobs = 8;
        url."ssh://github.com/".insteadOf = "https://github.com/";
        user.useConfigOnly = true;
      };
      includes = [
        {
          contents.user.email = "mmendez@equinix.com";
          condition = "gitdir:github.com/packethost/";
        }
        {
          contents.user.email = "mmendez@equinix.com";
          condition = "gitdir:github.com/tinkerbell/";
        }
      ];
      lfs.enable = true;
      userEmail = "mmendez534@gmail.com";
      userName = "Manuel Mendez";
    };
    kakoune = {
      enable = true;
      config = {
        colorScheme = "gruvbox";
        /* hooks = [{
             name = "BufWritePost";
             group = "format";
             option = ".*\\.go";
             commands = ''
               %{ evaluate-commands %sh{ goimports -e -w "$kak_buffile" }; edit!}'';
           }];
        */
        numberLines = {
          enable = true;
          relative = true;
          highlightCursor = true;
          separator = ''"| "'';
        };
        showMatching = true;
      };
      extraConfig = ''
        ## Extra Config ##
        #set-option global idle_timeout 200
        set-option global windowing_modules 'x11'
        hook global ModuleLoaded x11 %{
          set-option global termcmd 'kitty sh -c'
        }

        source "%val{config}/plugins/plug.kak/rc/plug.kak"

        plug 'mreppen/kakoune-sway' %{
          # Suggested mapping
          map global user 3 ': enter-user-mode sway<ret>' -docstring 'Sway…'
        }

        #plug "robertmeta/plug.kak" noload
        plug "mmlb/plug.kak" noload

        plug "Screwtapello/kakoune-inc-dec" domain "gitlab.com"
        map global normal <c-a> \
            ': inc-dec-modify-numbers + %val{count}<ret>'
        map global normal <c-x> \
            ': inc-dec-modify-numbers - %val{count}<ret>'

        plug "ul/kak-tree" do %{
            nix-shell -p cargo gcc --run 'cargo install --locked --force --path .  --features "bash go html python ruby"'
        }

        plug "kak-lsp/kak-lsp" do %{
            nix-shell -p cargo gcc --run "cargo install --locked --force --path ."
        }
        lsp-enable
        lsp-auto-hover-enable
        set-option global lsp_show_hover_format 'printf %s "$\{lsp_diagnostics}"'

        #hook -group format global BufWritePost .*\.go %{ evaluate-commands %sh{ goimports -e -w "$kak_buffile" }; edit! }
        hook -group format global BufWritePost .*\.go %{ evaluate-commands %sh{ goimports -e -w "$kak_buffile" }; edit! }
        hook -group format global BufWritePost .*\.sh %{ evaluate-commands %sh{ shfmt -s -w "$kak_buffile" }; edit! }
      '';
    };
    home-manager.enable = true;
    mako.enable = true;
    waybar = {
      enable = true;
      settings = [{
        layer = "top";
        position = "top";
        modules-left = [ "sway/workspaces" "custom/right-arrow-dark" ];
        modules-center = [
          "custom/left-arrow-dark"
          "clock#1"
          "custom/left-arrow-light"
          "custom/left-arrow-dark"
          "clock#2"
          "custom/right-arrow-dark"
          "custom/right-arrow-light"
          "clock#3"
          "custom/right-arrow-dark"
        ];
        modules-right = [
          "custom/left-arrow-dark"
          "pulseaudio"
          "custom/left-arrow-light"
          "custom/left-arrow-dark"
          "memory"
          "custom/left-arrow-light"
          "custom/left-arrow-dark"
          "cpu"
          "custom/left-arrow-light"
          "custom/left-arrow-dark"
          "battery"
          "custom/left-arrow-light"
          "custom/left-arrow-dark"
          "disk"
          "custom/left-arrow-light"
          "custom/left-arrow-dark"
          "tray"
        ];
        modules = {
          "custom/left-arrow-dark" = {
            format = "";
            tooltip = false;
          };
          "custom/left-arrow-light" = {
            format = "";
            tooltip = false;
          };
          "custom/right-arrow-dark" = {
            format = "";
            tooltip = false;
          };
          "custom/right-arrow-light" = {
            format = "";
            tooltip = false;
          };
          "sway/workspaces" = {
            disable-scroll = true;
            format = "{name}";
          };
          "clock#1" = {
            format = "{:%a}";
            tooltip = false;
          };
          "clock#2" = {
            format = "{:%H:%M}";
            tooltip = false;
          };
          "clock#3" = {
            format = "{:%m-%d}";
            tooltip = false;
          };
          pulseaudio = {
            format = "{icon} {volume:2}%";
            format-bluetooth = "{icon}  {volume}%";
            format-muted = "MUTE";
            format-icons = {
              headphones = "";
              default = [ "" "" ];
            };
            scroll-step = 5;
            on-click = "pamixer -t";
            on-click-right = "pavucontrol";
          };
          memory = {
            interval = 5;
            format = "Mem {}%";
          };
          cpu = {
            interval = 5;
            format = "CPU {usage:2}%";
          };
          battery = {
            states = {
              good = 95;
              warning = 30;
              critical = 15;
            };
            format = "{icon} {capacity}%";
            format-icons = [ "" "" "" "" "" ];
          };
          disk = {
            interval = 5;
            format = "Disk {percentage_used:2}%";
            path = "/";
          };
          tray = { icon-size = 20; };
        };
      }];
      style = ''
        * {
        	font-size: 20px;
        	font-family: iosevka;
        }

        window#waybar {
        	background: #292b2e;
        	color: #fdf6e3;
        }

        #custom-right-arrow-dark,
        #custom-left-arrow-dark {
        	color: #1a1a1a;
        }
        #custom-right-arrow-light,
        #custom-left-arrow-light {
        	color: #292b2e;
        	background: #1a1a1a;
        }

        #workspaces,
        #clock.1,
        #clock.2,
        #clock.3,
        #pulseaudio,
        #memory,
        #cpu,
        #battery,
        #disk,
        #tray {
        	background: #1a1a1a;
        }

        #workspaces button {
        	padding: 0 2px;
        	color: #fdf6e3;
        }
        #workspaces button.focused {
        	color: #268bd2;
        }
        #workspaces button:hover {
        	box-shadow: inherit;
        	text-shadow: inherit;
        }
        #workspaces button:hover {
        	background: #1a1a1a;
        	border: #1a1a1a;
        	padding: 0 3px;
        }

        #pulseaudio {
        	color: #268bd2;
        }
        #memory {
        	color: #2aa198;
        }
        #cpu {
        	color: #6c71c4;
        }
        #battery {
        	color: #859900;
        }
        #disk {
        	color: #b58900;
        }

        #clock,
        #pulseaudio,
        #memory,
        #cpu,
        #battery,
        #disk {
        	padding: 0 10px;
        }
      '';
    };
  };
}
