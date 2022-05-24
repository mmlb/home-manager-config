{ config, lib, pkgs, ... }:
let
  prependPaths = [
    "${config.home.homeDirectory}/bin"
    "${config.home.homeDirectory}/go/bin"
    "${config.home.homeDirectory}/.local/bin"
  ];

  gdlv = pkgs.buildGoModule rec {
    pname = "gdlv";
    version = "1.7.0";
    src = pkgs.fetchFromGitHub {
      owner = "aarzilli";
      repo = pname;
      rev = "v${version}";
      sha256 = "1jr7y5q7az2bkz43r12snfdjk8jdn281ys8r716am2nvgqax0z44";
    };
    vendorSha256 = null;
  };

  tcat = pkgs.buildGoModule rec {
    pname = "tcat";
    version = "1.0.0";
    src = pkgs.fetchFromGitHub {
      owner = "rsc";
      repo = pname;
      rev = "v${version}";
      sha256 = "1szzfz5xsx9l8gjikfncgp86hydzpvsi0y5zvikd621xkp7g7l21";
    };
    vendorSha256 = "0sjjj9z1dhilhpc8pq4154czrb79z9cm044jvn75kxcjv6v5l2m5";
  };

  goPackages = with pkgs; [
    asmfmt
    delve
    #errcheck
    gdlv
    gnused
    go
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
    gotags
    gotools
    iferr
    impl
    reftools
    tcat
  ];

in {
  imports = [ ./programs.nix ./sway.nix ];
  home.activation.report-changes = config.lib.dag.entryAnywhere ''
    ${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath
  '';
  home.packages = with pkgs;
    [
      alacritty
      asciinema
      bat
      bitwarden-cli
      blueman
      broot
      colordiff
      delta
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
      go-2fa
      gron
      gtk3
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
      noisetorch
      nvd
      pamixer
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
      tmate
      tmux
      tree
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
    ] ++ goPackages;

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
      use github.com/zzamboni/elvish-completions/ssh
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
      fn commit-nixpkgs { echo "update\n\n"(nix-github-compare|slurp) | git commit -F- . }
      fn cp {|@a| e:cp --reflink=auto $@a}
      fn d {|@a| et dev $@a}
      fn dc {|@a| docker-compose $@a}
      fn grep {|@a| e:git grep --no-index --exclude-standard --color=auto $@a}
      fn init-direnv {|| echo "has nix && use nix\ndotenv_if_exists" >> .envrc; touch shell.nix; direnv allow . }
      fn ls {|@a| e:ls --color=auto -FH --group-directories-first $@a}
      fn nix-shell {|@a| e:nix-shell --command elvish $@a}
      fn please {|@a| sudo $@a}
      fn tar {|@a| bsdtar $@a}
      fn tf {|@a| terraform $@a}
      fn tree {|@a| broot $@a}
      fn vim {|@a| nvim $@a}
      fn xargs {|@a| e:xargs -I % -n 1 -P (nproc) $@a}
      fn xssh {|@a| tmp E:TERM = xterm-256color; e:ssh $@a}
      fn xterm {|@a| e:xterm -f "${config.xdg.configHome}/xterm/xterm.conf" $@a}
      fn z {|@a| et zdev $@a}
      fn zsh {|@a| set-env ZSH_NO_EXEC_ELVISH 1; e:zsh $@a}

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
  };
  home.sessionVariables = {
    EDITOR = "${pkgs.kakoune}/bin/kak";
    KEYTIMEOUT = "1";
    LESS = "AFRSX";
    VISUAL = "${config.home.sessionVariables.EDITOR}";
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_TYPE = "wayland";
    XKB_DEFAULT_OPTIONS = "ctrl:nocaps";
    PATH = "${lib.strings.concatStringsSep ":" prependPaths}:$PATH";
  };

  nixpkgs.config = { andrdoid_sdk.accept_license = true; };

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
  systemd.user.tmpfiles.rules =
    [ "D ${config.xdg.cacheHome}/ssh/control-master/ - - - - -" ];

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
