{
  config,
  pkgs,
  ...
}: {
  programs = {
    direnv = {
      enable = true;
      stdlib = ''
        use_nix() {
                eval "$(lorri direnv)"
        }
      '';
    };
    fish = {
      enable = true;
      interactiveShellInit = ''
        set -x MAKEFLAGS -j(math (nproc) + 1)
        set -x TMPDIR $XDG_RUNTIME_DIR/tmp
        test -d $TMPDIR; or mkdir -p $TMPDIR
        function update_prompt_prexec --on-event="fish_preexec"; update_prompt_time "$argv"; end
      '';
      functions = {
        grep.body = ''
          if test -t 0
              git grep --no-index --exclude-standard --color=auto $argv
          else
              command grep $argv
          end
        '';
        vagrant.body = ''
          if (count $argv) -gt 0; and test $argv[1] = ssh-config
              command vagrant $argv | sed 's|IdentityFile|PubkeyAuthentication yes\n  SetEnv TERM=xterm-256color\n  &|'
          else
              command vagrant $argv
          end
        '';
        fish_prompt.body = ''
          set y (set_color bryellow)
          set r (set_color red)
          printf -- $r'['$y'--:--:--'$r']-['$y(prompt_pwd)$r']-['(prompt_login)$r']\n\n'
        '';
        update_prompt_time.body = ''
          set ignores clear exit reset

          # clear & reset always erase history so no need to update the timestamp
          if contains $argv $ignore
              return
          end

          # the earliest elvish has SHLVL=2 so anything greater is run in a subshell that is probably being used interactively
          # lower leveled shells will most likely close the terminal window and thus no need to update the timestamp
          if test $SHLVL -gt 2; and contains $argv $ignore
              return
          end

          set lines 1
          set lens (string length --visible $argv)
          set cols (tput cols)
          for l in $lens
              set lines (math "$lines + ceil($l/$cols)")
          end

          if test $lines -eq 1
              set lines 2
          end

          set y (set_color bryellow)
          set r (set_color red)

          tput sc
          tput cuu $lines
          printf -- $r'['$y(date +%H:%M:%S)
          tput rc

          commandline -f repaint
        '';
      };
      shellAliases = {
        a = "et adev";
        cat = "bat";
        cp = "cp --reflink=auto";
        dc = "docker-compose";
        ls = "ls --color=auto -FH --group-directories-first";
        nix-shell = "nix-shell --command fish";
        tar = "bsdtar";
        tf = "terraform";
        tree = "broot";
        vim = "nvim";
        xssh = "TERM=xterm-256color ssh";
        zsh = "ZSH_NO_EXEC_REAL_SHELL=1 command zsh";
      };
    };
    foot = {
      enable = true;
      settings = {
        main = {
          font = "VictorMono SemiBold:size=16";
          dpi-aware = "no";
        };
        colors = {
          # Gruvbox
          background = "282828";
          foreground = "ebdbb2";

          regular0 = "282828";
          regular1 = "cc241d";
          regular2 = "98971a";
          regular3 = "d79921";
          regular4 = "458588";
          regular5 = "b16286";
          regular6 = "689d6a";
          regular7 = "a89984";

          bright0 = "928374";
          bright1 = "fb4934";
          bright2 = "b8bb26";
          bright3 = "fabd2f";
          bright4 = "83a598";
          bright5 = "d3869b";
          bright6 = "8ec07c";
          bright7 = "ebdbb2";
        };
        mouse = {
          #color = "82aaff";
          hide-when-typing = "yes";
        };
      };
    };
    fzf.enable = true;
    gh = {
      enable = true;
      enableGitCredentialHelper = true;
      settings.aliases = {
        co = "pr checkout";
        pv = "pr view";
      };
    };
    git = {
      enable = true;
      aliases = {
        hub = "!${pkgs.gitAndTools.hub}/bin/hub";
        dft = "difftool";
        lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        log1 = "log --oneline";
        log1m = "log --oneline master..";
        log1r = "log --oneline --reverse";
        log1rm = "log --oneline --reverse master..";
        mt = "!mergetool";
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
          tool = "difftastic";
        };
        difftool = {
          prompt = false;
          "difftastic" = {cmd = ''difft "$LOCAL" "$REMOTE"'';};
        };
        help.autoCorrect = 1;
        init.defaultBranch = "main";
        interactive.diffFilter = "delta --diff-so-fancy --color-only";
        log.date = "auto:human";
        merge = {
          autoStash = true;
          log = true;
          tool = "meld";
          renameLimit = 2048;
        };
        mergetool = {
          keepBackup = false;
          prompt = "no";
        };
        pager = {
          difftool = true;
          diff = "delta --diff-so-fancy";
          show = "delta --diff-so-fancy";
        };
        pull.rebase = true;
        push = {
          default = "current";
          followTags = true;
        };
        rebase = {
          autoSquash = true;
          autoStash = true;
          stat = true;
        };
        rerere.enabled = true;
        submodule.fetchJobs = 8;
        submodule.recurse = true;
        user.useConfigOnly = true;
      };
      includes = [
        {
          condition = "gitdir:github.com/";
          contents.user.email = "github@i.m.mmlb.dev";
        }
        {
          condition = "gitdir:gitlab.com/";
          contents.user.email = "gitlab@i.m.mmlb.dev";
        }
        {
          condition = "gitdir:sr.ht/";
          contents.user.email = "srht@i.m.mmlb.dev";
        }
      ];
      lfs.enable = true;
      userEmail = "git@i.m.mmlb.dev";
      userName = "Manuel Mendez";
    };
    helix = {
      enable = true;
      settings = {
        theme = "gruvbox";
      };
    };
    kakoune = {
      enable = true;
      config = {
        colorScheme = "gruvbox-dark";
        hooks = [
          {
            name = "BufOpenFile";
            option = ".*";
            commands = "modeline-parse";
          }
          {
            name = "BufSetOption";
            group = "format";
            option = "filetype=go";
            commands = ''
              set-option buffer formatcmd "goimports -e"
              set-option global disabled_hooks .*-insert
            '';
          }
          {
            name = "BufSetOption";
            option = "filetype=make";
            commands = "set-option buffer filetype makefile";
          }
          {
            name = "BufSetOption";
            group = "format";
            option = "filetype=nix";
            commands = ''
              %sh{
                formatcmd=$(which alejandra &>/dev/null && echo alejandra)
                formatcmd=''${formatcmd:-nixfmt}
                echo "set-option buffer formatcmd '$formatcmd'" >$kak_command_fifo
                echo "lsp-auto-hover-disable" >$kak_command_fifo
              }
            '';
          }
          {
            name = "BufSetOption";
            group = "format";
            option = "filetype=python";
            commands = ''set-option buffer formatcmd "black -" '';
          }
          {
            name = "BufSetOption";
            group = "format";
            option = "filetype=sh";
            commands = ''set-option buffer formatcmd "shfmt -s" '';
          }
          {
            name = "BufSetOption";
            group = "format";
            option = "filetype=yaml";
            commands = ''set-option buffer formatcmd "prettier --parser=yaml" '';
          }
          {
            name = "BufWritePost";
            group = "format";
            option = ".*";
            commands = "try %{ evaluate-commands format }";
          }
          {
            name = "WinSetOption";
            option = "filetype=zig";
            commands = ''
              # configure zls: we enable zig fmt, reference and semantic highlighting
              set-option buffer formatcmd 'zig fmt --stdin'
              set-option window lsp_auto_highlight_references true
              #set-option global lsp_server_configuration zls.zig_lib_path="/usr/lib/zig"
              set-option -add global lsp_server_configuration zls.warn_style=true
              set-option -add global lsp_server_configuration zls.enable_semantic_tokens=true
              hook window -group semantic-tokens BufReload .* lsp-semantic-tokens
              hook window -group semantic-tokens NormalIdle .* lsp-semantic-tokens
              hook window -group semantic-tokens InsertIdle .* lsp-semantic-tokens
              hook -once -always window WinSetOption filetype=.* %{
                  remove-hooks window semantic-tokens
              }
            '';
          }
          {
            name = "KakBegin";
            option = ".*";
            commands = "try %{ source ${config.home.homeDirectory}/.local/share/kak/kak_history }";
          }
          {
            name = "KakEnd";
            option = ".*";
            commands = "echo -to-file ${config.home.homeDirectory}/.local/share/kak/kak_history -quoting kakoune reg : %reg{:}";
          }
        ];
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

        plug "andreyorst/plug.kak" noload
        plug "Bodhizafa/kak-rainbow" # run rainbow-{enable,disable}-window

        plug "mmlb/kak-fetch"
        plug "mreppen/kakoune-sway" %{
          # Suggested mapping
          map global user 3 ': enter-user-mode sway<ret>' -docstring 'Sway…'
        }
        plug "notramo/elvish.kak" domain "git.tchncs.de"

        plug "Screwtapello/kakoune-inc-dec" domain "gitlab.com"
        map global normal <c-a> \
            ': inc-dec-modify-numbers + %val{count}<ret>'
        map global normal <c-x> \
            ': inc-dec-modify-numbers - %val{count}<ret>'

        plug "ul/kak-tree" do %{
            nix-shell -p cargo gcc --run 'cargo build --release --locked --features "bash go html python ruby" && cargo install --force --features "bash go html python ruby" --path .'
        }

        plug "kak-lsp/kak-lsp" do %{
            nix-shell -p cargo gcc --run 'cargo build --release --locked && cargo install --force --path .'
        }
        lsp-enable
        lsp-auto-hover-enable
        set-option global lsp_show_hover_format 'printf %s "''${lsp_diagnostics}"'
        set-option global ui_options ncurses_wheel_scroll_amount=1
        # kak: set filetype=kak
      '';
    };
    home-manager.enable = true;
    mako.enable = true;
    ssh = {
      enable = true;
      compression = true;
      controlMaster = "auto";
      controlPath = "${config.xdg.cacheHome}/ssh/control-master/%C.sock";
      controlPersist = "15m";
      extraConfig = ''
        KexAlgorithms = diffie-hellman-group-exchange-sha256,diffie-hellman-group14-sha1,diffie-hellman-group1-sha1
        PubKeyAuthentication = no
      '';
      includes = [
        "~/.ssh/packet-ssh-config/config_packet"
        "~/.ssh/include.d/*.config"
      ];
      matchBlocks = {
        "*" = {
          identitiesOnly = true;
          extraOptions = {};
        };
        "*.packet.net *.packet.rocks *.packethost.net" = {
          extraOptions = {"SetEnv" = "TERM=xterm-256color";};
        };
        "*.lan *.local" = {
          identityFile = ["~/.ssh/id_ed25519"];
          extraOptions = {"PubKeyAuthentication" = "yes";};
        };
        "bartender" = {
          hostname = "bartender.dixiepineacres.com";
          identityFile = ["~/.ssh/id_ed25519"];
          extraOptions = {"PubKeyAuthentication" = "yes";};
          user = "root";
        };
        "porter" = {
          hostname = "57941012.packethost.net";
          identityFile = ["~/.ssh/packethost_ed25519"];
          extraOptions = {"PubKeyAuthentication" = "yes";};
          user = "root";
        };
        "waiter" = {
          hostname = "58ee5b80.packethost.net";
          identityFile = ["~/.ssh/packethost_ed25519"];
          extraOptions = {"PubKeyAuthentication" = "yes";};
          user = "root";
        };
        "github.com gist.github.com" = {
          identityFile = ["~/.ssh/github_id_ed25519"];
          extraOptions = {"PubKeyAuthentication" = "yes";};
          user = "git";
        };
        "gitlab.com" = {
          identityFile = ["~/.ssh/gitlab"];
          extraOptions = {"PubKeyAuthentication" = "yes";};
          user = "git";
        };
        "gitlab.alpinelinux.org" = {
          identityFile = ["~/.ssh/gitlab.alpinelinux.org"];
          extraOptions = {"PubKeyAuthentication" = "yes";};
          user = "git";
        };
        "git.sr.ht" = {
          identityFile = ["~/.ssh/id_srht"];
          extraOptions = {"PubKeyAuthentication" = "yes";};
          user = "git";
        };
        "nix350 nix350.lan nix710 nix710.lan" = {
          hostname = "192.168.2.125";
          identityFile = ["~/.ssh/id_ed25519"];
          extraOptions = {"PubKeyAuthentication" = "yes";};
          user = "manny";
        };
        "dellnix dellnix.lan" = {
          hostname = "192.168.2.70";
          identityFile = ["~/.ssh/id_ed25519"];
          extraOptions = {"PubKeyAuthentication" = "yes";};
          user = "manny";
        };
        "zennix zennix.lan zdev" = {
          hostname = "192.168.2.127";
          identityFile = ["~/.ssh/id_ed25519"];
          extraOptions = {"PubKeyAuthentication" = "yes";};
          user = "manny";
        };
        "router.lan router" = {
          hostname = "192.168.1.1";
          identityFile = ["~/.ssh/id_ed25519"];
          extraOptions = {"PubKeyAuthentication" = "yes";};
          user = "root";
        };
        "adev" = {
          hostname = "f9d67017.packethost.net";
          identityFile = ["~/.ssh/packet-ssh-config/packethost_ed25519"];
          extraOptions = {
            "PubKeyAuthentication" = "yes";
            "SetEnv" = "TERM=xterm-256color";
          };
          user = "manny";
        };
        "dev" = {
          hostname = "dec786eb.packethost.net";
          identityFile = ["~/.ssh/packet-ssh-config/packethost_ed25519"];
          extraOptions = {"PubKeyAuthentication" = "yes";};
          user = "manny";
        };
      };
    };
    waybar = {
      enable = true;
      settings = [
        {
          layer = "top";
          position = "top";
          modules-left = ["sway/workspaces" "custom/right-arrow-dark"];
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
                default = ["" ""];
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
              format-icons = ["" "" "" "" ""];
            };
            disk = {
              interval = 5;
              format = "Disk {percentage_used:2}%";
              path = "/";
            };
            tray = {icon-size = 20;};
          };
        }
      ];
      systemd.enable = true;
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
    zoxide.enable = true;
  };
}
