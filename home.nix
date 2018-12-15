{ pkgs, ... }:

{
  home.packages = with pkgs; [
    alacritty
    direnv
    docker_compose
    elvish
    firefox-beta-bin
    font-manager
    freetype
    gettext
    git-lfs
    gnupg
    gotools
    gtk3
    gron
    hack-font
    htop
    inetutils
    inkscape
    ipmitool
    jo
    libjpeg_turbo
    mosh
    mpv
    mtr
    neovim
    nix-update-source
    pwgen
    python3Packages.python-language-server
    python3Packages.bpython
    socat
    sway-beta
    transmission-gtk
    wget
    vlc
    xclip
  ];

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };

  #programs.sway.enable = true;
  programs.home-manager = { enable = true; };
  programs.direnv = {
    enable = true;
    enableFishIntegration = false;
  };
}
