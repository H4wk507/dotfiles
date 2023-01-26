# Exports
export PATH="$HOME/scripts:$PATH"
export PATH="$HOME/.poetry/bin:$PATH"
export ZSH="$HOME/.oh-my-zsh"
export LS_COLORS="$(vivid generate snazzy)"

ZSH_THEME="eastwood"

# Update reminder
zstyle ':omz:update' mode reminder  # just remind me to update when it's time

DISABLE_AUTO_TITLE="false"

plugins=(git python zsh-autosuggestions zsh-syntax-highlighting)

# History settings
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

# Disable beep on error
unsetopt beep

bindkey -v

# Aliases
alias ls="ls --color=auto"
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias tor='cd ~/Documents/.tor-browser_en-US/ && ./start-tor-browser.desktop'
alias update='sudo apt update && sudo apt upgrade -y && sudo apt dist-upgrade'

# Autocompletion menu
zstyle ':completion:*' menu yes select
# Boost performance
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
DISABLE_UNTRACKED_FILES_DIRTY="true"

source $ZSH/oh-my-zsh.sh
