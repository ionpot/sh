ESC=$(printf "\e")
FG="\[$ESC[35m\]"
RST="\[$ESC(B$ESC[m\]"

export PS1="$FG\$$RST "
export PS2="$FG>$RST "

source $HOME/sh/.aliases
source $HOME/sh/.aliases-git
source $HOME/sh/.functions-git
