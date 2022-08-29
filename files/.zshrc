if [[ -d $HOME/go/src/github.com/packethost/eng-tools/bin ]]; then
	export PATH=$PATH:$HOME/go/src/github.com/packethost/eng-tools/bin
fi

if [[ -z $ZSH_NO_EXEC_REAL_SHELL ]]; then
	SHELL=$(which fish)
	exec "$SHELL"
fi

source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"

typeset -U PATH path

export MAKEFLAGS=-j$(($(nproc) + 1))
export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.socket
export TMPDIR=$XDG_RUNTIME_DIR/tmp

HISTFILE=~/.histfile
HISTSIZE=4096
SAVEHIST=4096
setopt extendedglob histignorealldups notify sharehistory
setopt auto_cd auto_pushd pushd_ignore_dups

bindkey -v
zstyle :compinstall filename '/home/manny/.zshrc'

autoload -Uz compinit
compinit

FZFZ_RECENT_DIRS_TOOL=fasd

alias cp='cp --reflink=auto'
alias dc='docker-compose'
alias grep='grep --color=auto'
alias l='ls -1'
alias ls='ls --color=auto'
alias nix-shell='command nix-shell --command zsh '
alias please=sudo
alias ssh='TERM=xterm ssh'
alias tar='bsdtar'
alias tf='terraform'
alias vim='nvim'
alias xargs='xargs -I "{}" -n 1 -P $(nproc)'

fpath=(~/.config/zsh/completions $fpath)

eval "$(direnv hook zsh)"

POWERLEVEL9K_GITSTATUS_DIR=${$(which gitstatusd):A:h:h}
source ~/configs/zsh/purepower.zsh

# BEGIN_KITTY_SHELL_INTEGRATION
if test -e "/nix/store/3h9l0ign99crp9525xmhn9rfn0l4r4q9-kitty-unstable-2021-11-03g68ad513dd/lib/kitty/shell-integration/kitty.zsh"; then source "/nix/store/3h9l0ign99crp9525xmhn9rfn0l4r4q9-kitty-unstable-2021-11-03g68ad513dd/lib/kitty/shell-integration/kitty.zsh"; fi
# END_KITTY_SHELL_INTEGRATION
