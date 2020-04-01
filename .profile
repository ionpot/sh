ESC=$(printf "\e")
FG="\[$ESC[35m\]"
RST="\[$ESC(B$ESC[m\]"

export PS1="$FG\$$RST "
export PS2="$FG>$RST "

export EDITOR=vim

source $HOME/sh/.load-aliases
