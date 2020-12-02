{ pkgs, ... }:

let
  lorri = (import ./lorri.nix { inherit pkgs; }) { };
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
    eternal-terminal
    evince
    fasd
    fd
    file
    firefox-bin
    #latest.firefox-nightly-bin
    flootty
    font-manager
    freetype
    fzf
    gettext
    gimp
    git
    git-crypt
    git-lfs
    git-revise
    gitAndTools.delta
    gitAndTools.diff-so-fancy
    gitAndTools.gh
    gitAndTools.git-absorb
    gitAndTools.gitstatus
    gitAndTools.hub
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
    hexyl
    htop
    hyperfine
    i3blocks
    i3status-rust
    inetutils
    inkscape
    ipcalc
    ipfs
    ipmitool
    jo
    jq
    keybase
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
    nodejs # for nvim Plug 'iamcco/markdown-preview.nvim'
    noisetorch
    pamixer
    pasystray
    pavucontrol
    pigz
    pipewire
    perl # needed by diff-so-fancy
    pssh
    pstree
    pulseeffects
    python3
    python3Packages.bpython
    python3Packages.python-language-server
    restic
    ripgrep
    rofi
    rsync
    shellcheck
    shfmt
    slurp
    socat
    sshpass
    tmate
    tmux
    transmission-gtk
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
    yarn # for nvim Plug 'iamcco/markdown-preview.nvim'
    zoom-us
  ];

  home.file.".elvish/rc.elv".text = ''
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
    fn ssh [@a]{ E:TERM=xterm e:ssh $@a }
    fn tar [@a]{ bsdtar $@a }
    fn tf [@a]{ terraform $@a }
    fn tree [@a]{ broot $@a }
    fn vim [@a]{ nvim $@a }
    fn xargs [@a]{ e:xargs -I "{}" -n 1 -P (nproc) $@a }
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

  #nixpkgs.overlays = [ (import "${mozilla-overlays}") ];
  nixpkgs.config = {
    allowUnfree = true;
    andrdoid_sdk.accept_license = true;
  };

  programs = {
    direnv = {
      enable = true;
      enableFishIntegration = false;
      stdlib = ''
        use_nix() {
                eval "$(lorri direnv)"
        }

        layout_python-venv() {
                local python=$${1:-python3}
                [[ $# -gt 0 ]] && shift
                unset PYTHONHOME
                if [[ -n $VIRTUAL_ENV ]]; then
                        VIRTUAL_ENV=$(realpath "$${VIRTUAL_ENV}")
                else
                        local python_version
                        python_version=$("$python" -c "import platform; print(platform.python_version())")
                        if [[ -z $python_version ]]; then
                                log_error "Could not detect Python version"
                                return 1
                        fi
                        VIRTUAL_ENV=$PWD/.direnv/python-venv-$python_version
                fi
                export VIRTUAL_ENV
                if [[ ! -d $VIRTUAL_ENV ]]; then
                        log_status "no venv found; creating $VIRTUAL_ENV"
                        "$python" -m venv "$VIRTUAL_ENV"
                fi

                PATH="$${VIRTUAL_ENV}/bin:$${PATH}"
                export PATH
        }
      '';
    };
    fzf.enable = true;
    kakoune = {
      enable = true;
      config = {
        colorScheme = "gruvbox";
        /* hooks = [{
             name = "BufWritePost";
             group = "format";
             option = ".*\\.go";
             commands = ''
               %{ evaluate-commands %sh{ goimports -e -w "$kak_buffile" }; edit!}'';
           }];
        */
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

        plug 'mreppen/kakoune-sway' %{
          # Suggested mapping
          map global user 3 ': enter-user-mode sway<ret>' -docstring 'Sway…'
        }

        #plug "robertmeta/plug.kak" noload
        plug "mmlb/plug.kak" noload

        plug "Screwtapello/kakoune-inc-dec" domain "gitlab.com"
        map global normal <c-a> \
            ': inc-dec-modify-numbers + %val{count}<ret>'
        map global normal <c-x> \
            ': inc-dec-modify-numbers - %val{count}<ret>'

        plug "ul/kak-tree" do %{
            nix-shell -p cargo gcc --run 'cargo install --locked --force --path .  --features "bash go html python ruby"'
        }

        plug "kak-lsp/kak-lsp" do %{
            nix-shell -p cargo gcc --run "cargo install --locked --force --path ."
        }
        lsp-enable
        lsp-auto-hover-enable
        set-option global lsp_show_hover_format 'printf %s "$\{lsp_diagnostics}"'

        #hook -group format global BufWritePost .*\.go %{ evaluate-commands %sh{ goimports -e -w "$kak_buffile" }; edit! }
        hook -group format global BufWritePost .*\.go %{ evaluate-commands %sh{ goimports -e -w "$kak_buffile" }; edit! }
        hook -group format global BufWritePost .*\.sh %{ evaluate-commands %sh{ shfmt -s -w "$kak_buffile" }; edit! }
      '';
    };
    home-manager.enable = true;
    mako.enable = true;
  };

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
  };
}
