{ pkgs, ... }: {

  programs = {
    direnv = {
      enable = true;
      enableFishIntegration = false;
      stdlib = ''
        use_nix() {
                eval "$(lorri direnv)"
        }
      '';
    };
    fzf.enable = true;
    git = {
      enable = true;
      aliases = {
        hub = "!${pkgs.gitAndTools.hub}/bin/hub";
        lg =
          "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        log1 = "log --oneline";
        log1m = "log --oneline master..";
        log1r = "log --oneline --reverse";
        log1rm = "log --oneline --reverse master..";
        mt = "!mergetool";
      };
      delta = {
        enable = false;
        options = { };
      };
      extraConfig = {
        advice.implicitIdentity = false;
        branch.autoSetupRebase = "always";
        checkout.defaultRemote = "origin";
        color.ui = true;
        commit.verbose = true;
        core.pager = "delta --diff-so-fancy";
        diff = {
          renameLimit = 2048;
          algorithm = "histogram";
          renames = "copies";
          submodule = "log";
        };
        difftool.prompt = "no";
        help.autoCorrect = 1;
        interactive.diffFilter = "delta --diff-so-fancy --color-only";
        log.date = "auto:human";
        merge = {
          log = true;
          tool = "meld";
          renameLimit = 2048;
        };
        mergetool = {
          keepBackup = false;
          prompt = "no";
        };
        pager = {
          diff = "delta --diff-so-fancy";
          show = "delta --diff-so-fancy";
        };
        push = {
          default = "current";
          followTags = true;
        };
        rebase = {
          autoSquash = true;
          stat = true;
        };
        submodule.fetchJobs = 8;
        url."ssh://github.com/".insteadOf = "https://github.com/";
        user.useConfigOnly = true;
      };
      includes = [
        {
          contents.user.email = "mmendez@equinix.com";
          condition = "gitdir:github.com/packethost/";
        }
        {
          contents.user.email = "mmendez@equinix.com";
          condition = "gitdir:github.com/tinkerbell/";
        }
      ];
      lfs.enable = true;
      userEmail = "mmendez534@gmail.com";
      userName = "Manuel Mendez";
    };
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
}
