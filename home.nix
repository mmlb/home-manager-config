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
      ".zshrc".source = ./files/zshrc;
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
    configFile = {
      "elvish/rc.elv".text = ''
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
      "foot/themes/gruvbox-dark".source = ./files/foot-theme-gruvbox-dark.ini;
      "foot/themes/gruvbox-light".source = ./files/foot-theme-gruvbox-light.ini;
      "helix/themes/gruvbox-dark.toml".source = ./files/helix-theme-gruvbox-dark.toml;
      "helix/themes/gruvbox-ligh.toml".source = ./files/helix-theme-gruvbox-light.toml;
      "nix/nix.conf".text = ''
        cores = 0
      '';
      "tmux/tmux.conf".source = ./files/tmux.conf;
    };

    dataFile = {
      "elvish/lib/direnv.elv".text = ''
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
  };
  xresources.properties = {
    "Xft.dpi" = 192;
    "Zutty.font" = "Iosevka Term Nerd Font Complete";
    "Zutty.fontpath" = "/run/current-system/sw/share/X11/fonts";
    "Zutty.fontsize" = 24;
    "Zutty.shell" = "elvish";
  };
}
