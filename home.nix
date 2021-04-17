{ config, lib, pkgs, ... }:
let
  lorri = (import ./lorri.nix { inherit pkgs; }) { };
  zutty = (import ./zutty.nix) { inherit pkgs; };
  prependPaths = [
    "${config.home.homeDirectory}/bin"
    "${config.home.homeDirectory}/go/bin"
    "${config.home.homeDirectory}/.local/bin"
  ];

in {
  imports = [ ./programs.nix ./sway.nix ];
  home.packages = with pkgs; [
    alacritty
    asciinema
    bat
    bitwarden-cli
    broot
    blueman
    colordiff
    direnv
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
    git-crypt
    git-lfs
    git-revise
    gitAndTools.delta
    gitAndTools.gh
    gitAndTools.git-absorb
    gitAndTools.gitstatus
    gitAndTools.hub
    gitg
    simple-scan
    go
    go-2fa
    gotools
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
    nix-update-source
    nixfmt
    nodePackages.prettier
    noisetorch
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
    python3Packages.python-language-server
    restic
    ripgrep
    rofi
    rsync
    shellcheck
    shfmt
    signal-desktop
    slurp
    socat
    sshpass
    sway-contrib.grimshot
    tmate
    tmux
    tree
    vim
    v4l-utils
    vlc
    wf-recorder
    waybar
    wget
    wireshark-qt
    wl-clipboard
    wofi
    xclip
    xdg-user-dirs
    xdg_utils
    xterm
    zutty
  ];

  home.file = {
    ".cargo/config.toml".text = ''
      [net]
      git-fetch-with-cli = true
      [install]
      root = "${config.home.homeDirectory}/.local"
    '';
    ".elvish/rc.elv".text = ''
      config-files = [ ~/.ssh/config ~/.ssh/packet-ssh-config /etc/ssh/ssh_config /etc/ssh_config ]

      use direnv
      #use github.com/zzamboni/elvish-completions/git
      use github.com/zzamboni/elvish-completions/ssh
      use github.com/zzamboni/elvish-modules/long-running-notifications
      use github.com/xiaq/edit.elv/smart-matcher

      smart-matcher:apply

      #use github.com/zzamboni/elvish-themes/chain

      long-running-notifications:never-notify = [
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
      #long-running-notifications:notifier = [cmd duration start]{
      #  notify-send -t 5000 "Command Finished\nDuration "$duration"\nCommand  "$cmd
      #}
      long-running-notifications:threshold = 20

      fn cat [@a]{ bat $@a }
      fn commit-nixpkgs { echo "update\n\n"(nix-github-compare|slurp) | git commit -F- . }
      fn cp [@a]{ e:cp --reflink=auto $@a }
      fn dc [@a]{ docker-compose $@a }
      fn grep [@a]{ e:grep --color=auto $@a }
      fn ls [@a]{ e:ls --color=auto $@a }
      fn nix-shell [@a]{ e:nix-shell --command elvish $@a }
      fn please [@a]{ sudo $@a }
      fn xssh [@a]{ E:TERM=xterm-256color e:ssh $@a }
      fn tar [@a]{ bsdtar $@a }
      fn tf [@a]{ terraform $@a }
      fn tree [@a]{ broot $@a }
      fn vim [@a]{ nvim $@a }
      fn xargs [@a]{ e:xargs -I % -n 1 -P (nproc) $@a }
      fn xterm [@a]{ e:xterm -f "${config.xdg.configHome}/xterm/xterm.conf" $@a }
      fn zsh [@a]{ set-env ZSH_NO_EXEC_ELVISH 1; e:zsh $@a }
      fn k [@a]{ kubectl $@a }
      #fn debugpod[@a] { kubectl run -i --tty --rm debug --image=busybox --restart=Never -- /bin/bash $@a }
      fn kgetall { kubectl get (kubectl api-resources --verbs=list -o name | paste -sd, -) --ignore-not-found --show-kind -o wide '$NS' }
      #fn decode_kubernetes_secret[@a] { kubectl get secret $@a -o json | jq '.data | map_values(@base64d)' }
      fn ds { decode_kubernetes_secret }

      -override-wcwidth 🦀 2

      edit:prompt = {
        styled "\n[" red;
        styled (tilde-abbr $pwd) bright-yellow;
        styled ']' red;

        styled "─[" red
        styled (whoami) bright-green
        styled "@" bright-black
        styled (hostname) cyan
        styled "]> " red

        put "\n";
      }

      edit:rprompt = {  }
    '';
    ".elvish/lib/direnv.elv".text = ''
      ## hook for direnv
      after-chdir = [$@after-chdir [_]{
        try {
          m = [(direnv export elvish | from-json)]
          if (> (count $m) 0) {
            m = (all $m)
            keys $m | each [k]{
              if $m[$k] {
                set-env $k $m[$k]
              } else {
                unset-env $k
              }
            }
          }
        } except e {
          echo $e
        }
      }]

      @edit:before-readline = $@edit:before-readline {
        try {
          m = [(direnv export elvish | from-json)]
          if (> (count $m) 0) {
            m = (all $m)
            keys $m | each [k]{
              if $m[$k] {
                set-env $k $m[$k]
              } else {
                unset-env $k
              }
            }
          }
        } except e {
          echo $e
        }
      }
    '';
  };
  home.sessionVariables = {
    EDITOR = "${pkgs.kakoune}/bin/kak";
    KEYTIMEOUT = "1";
    LESS = "AFRSX";
    MANPAGER = "nvim -c 'set ft=man' -";
    VISUAL = "${config.home.sessionVariables.EDITOR}";
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_TYPE = "wayland";
    XKB_DEFAULT_OPTIONS = "ctrl:nocaps";
    PATH = "${lib.strings.concatStringsSep ":" prependPaths}:$PATH";
  };

  nixpkgs.config = { andrdoid_sdk.accept_license = true; };

  services = {
    lorri = {
      enable = true;
      package = lorri;
    };
    pasystray.enable = true;
    redshift = {
      enable = true;
      package = pkgs.redshift-wlr;
      latitude = "25.563944250922";
      longitude = "-80.391474366188";
      temperature = {
        day = 5700;
        night = 3500;
      };
    };
  };

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
      set -sg escape-time 10

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
