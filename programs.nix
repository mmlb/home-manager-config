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
