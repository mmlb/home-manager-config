{
  config,
  lib,
  pkgs,
  ...
}: let
  prependPaths = [
    "${config.home.homeDirectory}/bin"
    "${config.home.homeDirectory}/go/bin"
    "${config.home.homeDirectory}/.local/bin"
  ];

  goDevPackages = with pkgs; [
    asmfmt
    delve
    #errcheck
    gdlv
    go_1_18
    go-motion
    go-tools
    gocode
    gocode-gomod
    godef
    gofumpt
    gogetdoc
    golangci-lint
    #golint
    gomodifytags
    gopls
    gotools
    iferr
    impl
    reftools
  ];
  guitarPackages = with pkgs; [nootka guitarix];
in {
  imports = [./programs.nix ./sway.nix];
  home.activation.report-changes = config.lib.dag.entryAnywhere ''
    ${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath
  '';
  home.packages = with pkgs;
    [
      alacritty
      alejandra
      asciinema
      bat
      bitwarden-cli
      blueman
      broot
      chromium
      colordiff
      delta
      difftastic
      direnv
      dnsutils
      duperemove
      elvish
      entr
      eternal-terminal
      evince
      fd
      file
      firefox-wayland
      #font-manager
      foot
      freetype
      fzf
      gimp
      git
      git-absorb
      git-appraise
      git-crypt
      gitg
      git-lfs
      git-revise
      gitstatus
      gnused
      glow
      go-2fa
      gron
      gtk3
      helix
      hexyl
      htop
      hyperfine
      i3blocks
      i3status-rust
      inetutils
      inkscape
      ipcalc
      ipmitool
      jo
      jq
      kitty
      libarchive
      libjpeg_turbo
      libnotify
      light
      lshw
      meld
      mosh
      mpv
      mtr
      neovim
      nixfmt
      nix-update-source
      nodePackages.bash-language-server
      nodePackages.prettier
      nodePackages.pyright
      nvd
      pamixer
      parallel
      pasystray
      pavucontrol
      pigz
      pipewire
      pssh
      pstree
      pulseeffects-pw
      python3
      python3Packages.bpython
      python3Packages.python-lsp-server
      restic
      ripgrep
      rnix-lsp
      rofi
      rsync
      shellcheck
      shfmt
      signal-desktop
      simple-scan
      slurp
      socat
      sshpass
      sway-contrib.grimshot
      tcat
      tmate
      tmux
      tree
      unzip
      v4l-utils
      vim
      vlc
      waybar
      wf-recorder
      wget
      wireshark-qt
      wl-clipboard
      wofi
      xclip
      xdg-user-dirs
      xdg_utils
      xterm
    ]
    ++ goDevPackages
    ++ guitarPackages;

  home.file = {
    ".cargo/config.toml".text = ''
      [net]
      git-fetch-with-cli = true
      [install]
      root = "${config.home.homeDirectory}/.local"
    '';
    ".config/elvish/rc.elv".text = ''
      var config-files = [ ~/.ssh/config ~/.ssh/packet-ssh-config /etc/ssh/ssh_config /etc/ssh_config ]

      use direnv
      #use github.com/zzamboni/elvish-completions/git
      #use github.com/zzamboni/elvish-completions/ssh
      use github.com/zzamboni/elvish-modules/long-running-notifications
      use github.com/xiaq/edit.elv/smart-matcher

      smart-matcher:apply

      set long-running-notifications:never-notify = [
        bat
        emacs
        kak
        less
        more
        nano
        nvim
        vi
        vim
      ]
      set long-running-notifications:threshold = 20

      fn a {|@a| et adev $@a}
      fn cat {|@a| bat $@a}
      fn cp {|@a| e:cp --reflink=auto $@a}
      fn d {|@a| et dev $@a}
      fn dc {|@a| docker-compose $@a}
      fn grep {|@a| if ?(test -t 0) { e:git grep --no-index --exclude-standard --color=auto $@a } else { e:grep $@a }}
      fn ls {|@a| e:ls --color=auto -FH --group-directories-first $@a}
      fn nix-shell {|@a| e:nix-shell --command elvish $@a}
      fn tar {|@a| bsdtar $@a}
      fn tf {|@a| terraform $@a}
      fn tree {|@a| broot $@a}
      fn vagrant {|@a| if (and (> (count $a) 0) (eq $a[0] ssh-config)) { set a = $a[1..]; e:vagrant ssh-config $@a | sed 's|IdentityFile|PubkeyAuthentication yes\n  SetEnv TERM=xterm-256color\n  &|' } else { e:vagrant $@a } }
      fn vim {|@a| nvim $@a}
      fn xargs {|@a| e:xargs -I % -n 1 -P (nproc) $@a}
      fn xssh {|@a| tmp E:TERM = xterm-256color; e:ssh $@a}
      fn xterm {|@a| e:xterm -f "${config.xdg.configHome}/xterm/xterm.conf" $@a}
      fn z {|@a| et zdev $@a}
      fn zsh {|@a| set-env ZSH_NO_EXEC_REAL_SHELL 1; e:zsh $@a}

      -override-wcwidth 🦀 2

      set edit:prompt = {
        styled "\n" red

        styled "[" red
        styled "--:--:--" bright-yellow
        styled "]" red

        styled "-[" red
        styled (tilde-abbr $pwd) bright-yellow
        styled "]" red

        styled "─[" red
        styled (whoami) bright-green
        styled "@" bright-black
        styled (hostname) cyan
        styled "]> " red

        put "\n"
      }
      set edit:rprompt = {  }

      fn update-prompt-after-readline {|cmd|
        # clear & reset always erase history so no need to update the timestamp
        if (has-value [clear reset] $cmd) {
          return
        }
        # the earliest elvish has SHLVL=3 so anything greater is run in a subshell that is probably being used interactively
        # lower leveled shells will most likely close the terminal window and thus no need to update the timestamp
        if (and (< $E:SHLVL 4) (has-value [exit ""] $cmd)) {
          return
        }

        use math
        var lines = 1
        put $cmd | to-lines | each {|line|
          var len = (count $line)
          var cols = (tput cols)
          set lines = (+ $lines (exact-num (math:ceil (/ $len $cols))))
        }

        if (== 1 $lines) {
          set lines = 2
        }

        tput sc
        tput cuu $lines
        printf "%s%s" (styled "[" red) (styled (date +%H:%M:%S) bright-yellow)
        tput rc
      }
      set edit:after-readline = [$@edit:after-readline $update-prompt-after-readline~]

      # Filter the command history through the fzf program. This is normally bound to Ctrl-R.
      fn history {||
        var new-cmd = (
          edit:command-history &dedup &newest-first &cmd-only | to-terminated "\x00" | try {
            ${pkgs.fzf}/bin/fzf ^
              --exact ^
              --info=hidden ^
              --layout=reverse ^
              --no-multi ^
              --no-sort ^
              --read0 ^
              --query=$edit:current-command | slurp
          } catch {
            # If the user presses [Escape] to cancel the fzf operation it will exit with a non-zero status.
            # Ignore that we ran this function in that case.
            edit:redraw &full=$true
            return
          }
        )
        edit:redraw &full=$true
        set edit:current-command = $new-cmd
      }
      set edit:insert:binding[Ctrl-R] = {|| history >/dev/tty 2>&1 }

      eval (cat "${config.xdg.configHome}/lscolors/lscolors.elv")
    '';
    ".local/share/elvish/lib/direnv.elv".text = ''
      ## hook for direnv
      set after-chdir = [$@after-chdir {|_|
        try {
          var m = [(direnv export elvish | from-json)]
          if (> (count $m) 0) {
            set m = (all $m)
            keys $m | each {|k|
              if $m[$k] {
                set-env $k $m[$k]
              } else {
                unset-env $k
              }
            }
          }
        } catch e {
          echo $e
        }
      }]

      set @edit:before-readline = $@edit:before-readline {
        try {
          var m = [(direnv export elvish | from-json)]
          if (> (count $m) 0) {
            set m = (all $m)
            keys $m | each {|k|
              if $m[$k] {
                set-env $k $m[$k]
              } else {
                unset-env $k
              }
            }
          }
        } catch e {
          echo $e
        }
      }
    '';
    ".config/foot/themes/gruvbox-dark".text = ''
      [colors]
      background=282828
      foreground=ebdbb2
      regular0=282828
      regular1=cc241d
      regular2=98971a
      regular3=d79921
      regular4=458588
      regular5=b16286
      regular6=689d6a
      regular7=a89984
      bright0=928374
      bright1=fb4934
      bright2=b8bb26
      bright3=fabd2f
      bright4=83a598
      bright5=d3869b
      bright6=8ec07c
      bright7=ebdbb2
    '';
    ".config/foot/themes/gruvbox-light".text = ''
      [colors]
      background=fbf1c7
      foreground=3c3836
      regular0=fbf1c7
      regular1=cc241d
      regular2=98971a
      regular3=d79921
      regular4=458588
      regular5=b16286
      regular6=689d6a
      regular7=7c6f64
      bright0=928374
      bright1=9d0006
      bright2=79740e
      bright3=b57614
      bright4=076678
      bright5=8f3f71
      bright6=427b58
      bright7=3c3836
    '';
    ".config/helix/themes/gruvbox-dark.toml".text = ''
      # Author : Jakub Bartodziej <kubabartodziej@gmail.com>
      # The theme uses the gruvbox dark palette with standard contrast: github.com/morhetz/gruvbox

      "attribute" = "aqua1"
      "keyword" = { fg = "red1" }
      "keyword.directive" = "red0"
      "namespace" = "aqua1"
      "punctuation" = "orange1"
      "punctuation.delimiter" = "orange1"
      "operator" = "purple1"
      "special" = "purple0"
      "variable.other.member" = "blue1"
      "variable" = "fg1"
      "variable.builtin" = "orange1"
      "variable.parameter" = "fg2"
      "type" = "yellow1"
      "type.builtin" = "yellow1"
      "constructor" = { fg = "purple1", modifiers = ["bold"] }
      "function" = { fg = "green1", modifiers = ["bold"] }
      "function.macro" = "aqua1"
      "function.builtin" = "yellow1"
      "tag" = "red1"
      "comment" = { fg = "gray1", modifiers = ["italic"]  }
      "constant" = { fg = "purple1" }
      "constant.builtin" = { fg = "purple1", modifiers = ["bold"] }
      "string" = "green1"
      "constant.numeric" = "purple1"
      "constant.character.escape" = { fg = "fg2", modifiers = ["bold"] }
      "label" = "aqua1"
      "module" = "aqua1"

      "diff.plus" = "green1"
      "diff.delta" = "orange1"
      "diff.minus" = "red1"

      "warning" = { fg = "orange1", bg = "bg1" }
      "error" = { fg = "red1", bg = "bg1" }
      "info" = { fg = "aqua1", bg = "bg1" }
      "hint" = { fg = "blue1", bg = "bg1" }

      "ui.background" = { bg = "bg0" }
      "ui.linenr" = { fg = "bg4" }
      "ui.linenr.selected" = { fg = "yellow1" }
      "ui.statusline" = { fg = "fg1", bg = "bg2" }
      "ui.statusline.normal" = { fg = "fg1", bg = "bg2" }
      "ui.statusline.insert" = { fg = "fg1", bg = "blue0" }
      "ui.statusline.select" = { fg = "fg1", bg = "orange0" }
      "ui.statusline.inactive" = { fg = "fg4", bg = "bg1" }
      "ui.popup" = { bg = "bg1" }
      "ui.window" = { bg = "bg1" }
      "ui.help" = { bg = "bg1", fg = "fg1" }
      "ui.text" = { fg = "fg1" }
      "ui.text.focus" = { fg = "fg1" }
      "ui.selection" = { bg = "bg3", modifiers = ["reversed"] }
      "ui.cursor.primary" = { modifiers = ["reversed"] }
      "ui.cursor.match" = { bg = "bg2" }
      "ui.menu" = { fg = "fg1", bg = "bg2" }
      "ui.menu.selected" = { fg = "bg2", bg = "blue1", modifiers = ["bold"] }
      "ui.virtual.whitespace" = "bg2"

      "diagnostic" = { modifiers = ["underlined"] }

      "markup.heading" = "aqua1"
      "markup.bold" = { modifiers = ["bold"] }
      "markup.italic" = { modifiers = ["italic"] }
      "markup.link.url" = { fg = "green1", modifiers = ["underlined"] }
      "markup.link.text" = "red1"
      "markup.raw" = "red1"

      [palette]
      bg0 = "#282828" # main background
      bg1 = "#3c3836"
      bg2 = "#504945"
      bg3 = "#665c54"
      bg4 = "#7c6f64"

      fg0 = "#fbf1c7"
      fg1 = "#ebdbb2" # main foreground
      fg2 = "#d5c4a1"
      fg3 = "#bdae93"
      fg4 = "#a89984" # gray0

      gray0 = "#a89984"
      gray1 = "#928374"

      red0 = "#cc241d" # neutral
      red1 = "#fb4934" # bright
      green0 = "#98971a"
      green1 = "#b8bb26"
      yellow0 = "#d79921"
      yellow1 = "#fabd2f"
      blue0 = "#458588"
      blue1 = "#83a598"
      purple0 = "#b16286"
      purple1 = "#d3869b"
      aqua0 = "#689d6a"
      aqua1 = "#8ec07c"
      orange0 = "#d65d0e"
      orange1 = "#fe8019"
    '';
    ".config/helix/themes/gruvbox-light.toml".text = ''
      # Author : Rohan Jain <crodjer@pm.me>
      # Author : Jakub Bartodziej <kubabartodziej@gmail.com>
      # The theme uses the gruvbox light palette with standard contrast: github.com/morhetz/gruvbox

      "attribute" = "aqua1"
      "keyword" = { fg = "red1" }
      "keyword.directive" = "red0"
      "namespace" = "aqua1"
      "punctuation" = "orange1"
      "punctuation.delimiter" = "orange1"
      "operator" = "purple1"
      "special" = "purple0"
      "variable.other.member" = "blue1"
      "variable" = "fg1"
      "variable.builtin" = "orange1"
      "variable.parameter" = "fg2"
      "type" = "yellow1"
      "type.builtin" = "yellow1"
      "constructor" = { fg = "purple1", modifiers = ["bold"] }
      "function" = { fg = "green1", modifiers = ["bold"] }
      "function.macro" = "aqua1"
      "function.builtin" = "yellow1"
      "tag" = "red1"
      "comment" = { fg = "gray1", modifiers = ["italic"]  }
      "constant" = { fg = "purple1" }
      "constant.builtin" = { fg = "purple1", modifiers = ["bold"] }
      "string" = "green1"
      "constant.numeric" = "purple1"
      "constant.character.escape" = { fg = "fg2", modifiers = ["bold"] }
      "label" = "aqua1"
      "module" = "aqua1"

      "diff.plus" = "green1"
      "diff.delta" = "orange1"
      "diff.minus" = "red1"

      "warning" = { fg = "orange1", bg = "bg1" }
      "error" = { fg = "red1", bg = "bg1" }
      "info" = { fg = "aqua1", bg = "bg1" }
      "hint" = { fg = "blue1", bg = "bg1" }

      "ui.background" = { bg = "bg0" }
      "ui.linenr" = { fg = "bg4" }
      "ui.linenr.selected" = { fg = "yellow1" }
      "ui.statusline" = { fg = "fg1", bg = "bg2" }
      "ui.statusline.normal" = { fg = "fg1", bg = "bg2" }
      "ui.statusline.insert" = { fg = "fg1", bg = "blue0" }
      "ui.statusline.select" = { fg = "fg1", bg = "orange0" }
      "ui.statusline.inactive" = { fg = "fg4", bg = "bg1" }
      "ui.popup" = { bg = "bg1" }
      "ui.window" = { bg = "bg1" }
      "ui.help" = { bg = "bg1", fg = "fg1" }
      "ui.text" = { fg = "fg1" }
      "ui.text.focus" = { fg = "fg1" }
      "ui.selection" = { bg = "bg3", modifiers = ["reversed"] }
      "ui.cursor.primary" = { modifiers = ["reversed"] }
      "ui.cursor.match" = { bg = "bg2" }
      "ui.menu" = { fg = "fg1", bg = "bg2" }
      "ui.menu.selected" = { fg = "bg2", bg = "blue1", modifiers = ["bold"] }
      "ui.virtual.whitespace" = "bg2"

      "diagnostic" = { modifiers = ["underlined"] }

      "markup.heading" = "aqua1"
      "markup.bold" = { modifiers = ["bold"] }
      "markup.italic" = { modifiers = ["italic"] }
      "markup.link.url" = { fg = "green1", modifiers = ["underlined"] }
      "markup.link.text" = "red1"
      "markup.raw" = "red1"

      [palette]
      bg0 = "#fbf1c7" # main background
      bg1 = "#ebdbb2"
      bg2 = "#d5c4a1"
      bg3 = "#bdae93"
      bg4 = "#a89984"

      fg0 = "#282828" # main foreground
      fg1 = "#3c3836"
      fg2 = "#504945"
      fg3 = "#665c54"
      fg4 = "#7c6f64" # gray0

      gray0 = "#7c6f64"
      gray1 = "#928374"

      red0 = "#cc241d" # neutral
      red1 = "#9d0006" # bright
      green0 = "#98971a"
      green1 = "#79740e"
      yellow0 = "#d79921"
      yellow1 = "#b57614"
      blue0 = "#458588"
      blue1 = "#076678"
      purple0 = "#b16286"
      purple1 = "#8f3f71"
      aqua0 = "#689d6a"
      aqua1 = "#427b58"
      orange0 = "#d65d0e"
      orange1 = "#af3a03"
    '';
  };
  home.sessionVariables = {
    EDITOR = "${pkgs.kakoune}/bin/kak";
    KEYTIMEOUT = "1";
    LESS = "AFRSX";
    PATH = "${lib.strings.concatStringsSep ":" prependPaths}:$PATH";
    VISUAL = "${config.home.sessionVariables.EDITOR}";
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_TYPE = "wayland";
    XKB_DEFAULT_OPTIONS = "ctrl:nocaps";
  };
  home.stateVersion = "18.09";

  nixpkgs.config = {andrdoid_sdk.accept_license = true;};

  services = {
    lorri.enable = true;
    pasystray.enable = true;
    redshift = {
      enable = true;
      package = pkgs.gammastep;
      latitude = "29.621690";
      longitude = "-82.422049";
      temperature = {
        day = 5700;
        night = 3500;
      };
    };
    syncthing.enable = true;
  };
  systemd.user.tmpfiles.rules = ["D ${config.xdg.cacheHome}/ssh/control-master/ - - - - -"];

  xdg = {
    enable = true;
    configFile."nix/nix.conf".text = ''
      cores = 0
    '';
    configFile."tmux/tmux.conf".text = ''
      set -g prefix C-s
      unbind C-b
      bind C-s send-prefix

      set -g history-limit 10000
      set -g default-terminal "tmux-256color"
      set -sg escape-time 0

      set -g mouse

      set-window-option -g mode-keys vi
      #bind-key -t vi-copy 'v' begin-selection
      #bind-key -t vi-copy 'y' copy-selection

      unbind r
      bind r source-file ${config.xdg.configHome}/tmux/tmux.conf

      unbind l
      bind m last-window

      bind-key h select-pane -U
      bind-key j select-pane -L
      bind-key k select-pane -R
      bind-key l select-pane -D

      new-session -s default

      #set-environment -g TMUX_PLUGIN_MANAGER_PATH '~/.local/lib/tmux/plugins'
      #
      #set -g @plugin 'tmux-plugins/tmux-resurrect'
      #set -g @plugin 'tmux-plugins/tmux-continuum'
      #
      #set -g @continuum-restore 'on'
      #
      #run '~/.local/lib/tmux/plugins/tpm/tpm'
      #
      # Notes
      # Q: How to view different window on a different client/terminal?
      #    If you open a new terminal and try :next, both clients will see the window switch.
      #    This is because the windows being shown is per-session not per client.
      # A: Create a new session that is attached to the same windows as the other
      #    $ tmux new-session -t 'original session name or number'
      #    Now when done you can kill the new session but the windows stay around as long as a session is connected (the original)
    '';
  };

  xresources.properties = {
    "Xft.dpi" = 192;
    "Zutty.font" = "Iosevka Term Nerd Font Complete";
    "Zutty.fontpath" = "/run/current-system/sw/share/X11/fonts";
    "Zutty.fontsize" = 24;
    "Zutty.shell" = "elvish";
  };
}
