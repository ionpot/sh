export PATH="$HOME/depot_tools:$PATH"

autoload -U colors && colors
autoload -U compinit && compinit

# case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

PS1="%{$fg[blue]%}%1d%{$reset_color%}%# "

source $HOME/.aliases
source $HOME/.functions
