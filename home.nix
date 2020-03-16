{ pkgs, ... }:

let
  lorri = import (pkgs.fetchFromGitHub {
    owner = "target";
    repo = "lorri";
    #branch@date: master@2020-02-06
    rev = "b2f1fe218ab95ce7c89c4b35644d01c4c1f1b21d";
    sha256 = "0yliffg3kpmdi2nk1xjhizsnz03djnjj8pw5k3gryz7hh2cyvyx7";
  }) { };
  path = with pkgs; lib.makeSearchPath "bin" [ nix gnutar git ];
  mozilla-overlays = builtins.fetchTarball
    "https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz";

in {
  home.packages = with pkgs; [
    abduco
    alacritty
    asciinema
    bat
    bitwarden-cli
    broot
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
    latest.firefox-nightly-bin
    flootty
    font-manager
    freetype
    fzf
    gettext
    gimp
    git-crypt
    git-lfs
    git-revise
    gitAndTools.delta
    gitAndTools.diff-so-fancy
    gitAndTools.gh
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
    kitty
    libarchive
    libjpeg_turbo
    libnotify
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
    nixfmt
    nodejs # for nvim Plug 'iamcco/markdown-preview.nvim'
    pasystray
    pavucontrol
    pigz
    pipewire
    pssh
    pstree
    python3
    python3Packages.bpython
    python3Packages.python-language-server
    ripgrep
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
    wl-clipboard
    wofi
    xclip
    xdg-user-dirs
    xwayland
    yarn # for nvim Plug 'iamcco/markdown-preview.nvim'
    zoom-us
  ];

  nixpkgs.overlays = [ (import "${mozilla-overlays}") ];
  nixpkgs.config = {
    allowUnfree = true;
    andrdoid_sdk.accept_license = true;
    packageOverrides = pkgs: {
      python3 = pkgs.python3.override {
        packageOverrides = self: super:
          let
            importlib-metadata = super.importlib-metadata.overridePythonAttrs
              (old: rec {
                version = "1.3.0";
                src = super.fetchPypi {
                  pname = "importlib_metadata";
                  inherit version;
                  sha256 =
                    "0ibvvqajphwdclbr236gikvyja0ynvqjlix38kvsabgrf0jqafh7";
                };
              });
          in {
            tox = super.tox.overridePythonAttrs (old: rec {
              catchConflicts = false;
              buildInputs = old.buildInputs ++ [ importlib-metadata ];
            });
          };
      };
    };
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
  services.pasystray.enable = true;
  services.redshift = {
    enable = true;
    package = pkgs.redshift-wlr;
    latitude = "25.563944250922";
    longitude = "-80.391474366188";
    temperature = {
      day = 5700;
      night = 3500;
    };
  };
  services.syncthing.enable = true;

  systemd.user.sockets.lorri = {
    Unit = { Description = "lorri build daemon"; };
    Socket = { ListenStream = "%t/lorri/daemon.socket"; };
    Install = { WantedBy = [ "sockets.target" ]; };
  };

  systemd.user.services.lorri = {
    Unit = {
      Description = "lorri build daemon";
      Documentation = "https://github.com/target/lorri";
      ConditionUser = "!@system";
      Requires = "lorri.socket";
      After = "lorri.socket";
      RefuseManualStart = true;
    };

    Service = {
      ExecStart = "${lorri}/bin/lorri daemon";
      PrivateTmp = true;
      ProtectSystem = "strict";
      WorkingDirectory = "%h";
      Restart = "on-failure";
      Environment = "PATH=${path} RUST_BACKTRACE=1";
    };
  };
  xdg.enable = true;
}
