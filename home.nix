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
    elvish
    entr
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
    gnumake
    gnupg
    go
    gotools
    grim
    gron
    gtk3
    hack-font
    htop
    htop
    i3blocks
    inetutils
    inkscape
    ipcalc
    ipmitool
    jo
    jq
    keybase
    libarchive
    libjpeg_turbo
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
    sway
    swayidle
    swaylock
    transmission-gtk
    tree
    vlc
    #waybar
    wget
    xclip
    xwayland
    #zoom-us
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
