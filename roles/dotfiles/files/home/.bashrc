# ~/.bashrc

# colours
if [ "$TERM" != "dumb" ]; then
    RED="$(tput setaf 1)"
    GREEN="$(tput setaf 2)"
    RESET="$(tput sgr0)"
fi

# shell features
# 
shopt -s autocd
shopt -s cdspell
shopt -s checkhash
shopt -s checkwinsize
shopt -s cmdhist
shopt -s direxpand
#shopt -s dirspell
shopt -s globstar
shopt -s histappend
shopt -s mailwarn
shopt -s no_empty_cmd_completion
HISTCONTROL=ignoreboth

import() {
    for file; do
	if [[ -r "$file" ]]; then
	    # shellcheck disable=SC1090
	    source "$file"
	fi
    done
}

try_eval() {
    if command -v "$1" > /dev/null; then
	eval "$("$@")"
    else
	pkgfile -bv "$1"
    fi
}

slow_repo() {
    git config bash.showDirtyState false && git config bash.showUntrackedFiles false
}
if . /usr/share/git/git-prompt.sh > /dev/null 2>&1; then
    if [ -x "$(command -v watchman)" ]; then
	# shellcheck disable=SC2034
	GIT_PS1_SHOWDIRTYSTATE=y
	# shellcheck disable=SC2034
	GIT_PS1_SHOWUNTRACKEDFILES=y
    fi
    # shellcheck disable=SC2034
    GIT_PS1_SHOWSTASHSTATE=y
    # shellcheck disable=SC2034
    GIT_PS1_SHOWUPSTREAM=y
    PS1="\$(__git_ps1 \"(%s) \")$PS1"
fi

# colourize prompt according to command status
PS1="\\[$RED\\]\${?/#0/\\[$GREEN\\]}$PS1\\[$RESET\\]"

# shellcheck disable=SC1090
. "$HOME"/.aliases

import /{etc,usr{,/local}/share/bash-completion}/bash_completion
import /usr/share/doc/pkgfile/command-not-found.bash
try_eval direnv hook bash &
try_eval hub alias -s
try_eval thefuck --alias &
disown -a