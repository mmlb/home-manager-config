{ pkgs, ... }:

{
  nixpkgs.config = {
    allowUnfree = true;
  };

  home.packages = with pkgs; [
    alacritty
    colordiff
    direnv
    docker_compose
    duperemove
    elvish
    entr
    file
    firefox-beta-bin
    font-manager
    freetype
    fzf
    gettext
    gimp
    git-crypt
    git-lfs
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
    python3Packages.bpython
    python3Packages.python-language-server
    ripgrep
    rofi
    rsync
    shellcheck
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

  home.file.".config/nixpkgs/config.nix".text = ''
  {
    allowUnfree = true;
  }
  '';

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };

  #programs.sway.enable = true;
  programs.home-manager = {
    enable = true;
  };
  programs.direnv = {
    enable = true;
    enableFishIntegration = false;
  };
}
