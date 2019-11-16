{ pkgs, ... }:

let
  lorri = import (pkgs.fetchFromGitHub {
    owner = "target";
    repo = "lorri";
    rev = "03f10395943449b1fc5026d3386ab8c94c520ee3";
    sha256 = "0fcl79ndaziwd8d74mk1lsijz34p2inn64b4b4am3wsyk184brzq";
  }) { };
  path = with pkgs; lib.makeSearchPath "bin" [ nix gnutar git ];

in {
  home.packages = with pkgs; [
    alacritty
    asciinema
    bitwarden-cli
    blueman
    colordiff
    direnv
    docker_compose
    duperemove
    elvish
    entr
    evince
    fasd
    fd
    file
    firefox-beta-bin
    flootty
    font-manager
    freetype
    fzf
    gettext
    gimp
    git-crypt
    git-lfs
    git-revise
    gitAndTools.diff-so-fancy
    gitAndTools.git-absorb
    gitAndTools.gitstatus
    gitFull
    gitg
    gnome3.simple-scan
    gnumake
    gnupg
    go
    go-2fa
    gotools
    grim
    gron
    gtk3
    hack-font
    htop
    i3blocks
    i3status-rust
    inetutils
    inkscape
    ipcalc
    ipfs
    ipmitool
    jo
    jq
    kakoune
    keybase
    libarchive
    libjpeg_turbo
    light
    lorri
    lshw
    mako
    meld
    mosh
    mpv
    mtr
    neovim
    nix-update-source
    pasystray
    pavucontrol
    pstree
    python3
    python3Packages.bpython
    python3Packages.python-language-server
    ripgrep
    rofi
    rsync
    shellcheck
    shfmt
    slurp
    socat
    sshpass
    sway
    swayidle
    swaylock
    tmux
    transmission-gtk
    tree
    vim
    vlc
    #waybar
    wget
    wireshark-qt
    xclip
    xwayland
    zoom-us
  ];

  nixpkgs.config = {
    allowUnfree = true;
    andrdoid_sdk.accept_license = true;
  };

  programs.direnv = {
    enable = true;
    enableFishIntegration = false;
    stdlib = ''
      use_nix() {
        eval "$(lorri direnv)"
      }
    '';
  };
  programs.fzf = { enable = true; };
  programs.home-manager = { enable = true; };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };

  services.syncthing.enable = true;
  #
  #  systemd.user.sockets.lorri = {
  #    Unit = { Description = "lorri build daemon"; };
  #    Socket = { ListenStream = "%t/lorri/daemon.socket"; };
  #    Install = { WantedBy = [ "sockets.target" ]; };
  #  };
  #
  #  systemd.user.services.lorri = {
  #    Unit = {
  #      Description = "lorri build daemon";
  #      Documentation = "https://github.com/target/lorri";
  #      ConditionUser = "!@system";
  #      Requires = "lorri.socket";
  #      After = "lorri.socket";
  #      RefuseManualStart = true;
  #    };
  #
  #    Service = {
  #      ExecStart = "${lorri}/bin/lorri daemon";
  #      PrivateTmp = true;
  #      ProtectSystem = "strict";
  #      WorkingDirectory = "%h";
  #      Restart = "on-failure";
  #      Environment = "PATH=${path} RUST_BACKTRACE=1";
  #    };
  #  };

  xdg.enable = true;
}
