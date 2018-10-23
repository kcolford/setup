#!/bin/sh

export NAME="Kieran Colford"
export EMAIL="kieran@kcolford.com"

if [ -x /usr/bin/emacs ]; then
    export ALTERNATE_EDITOR="emacs -Q"
    export EDITOR="emacsclient -nw"
fi
export PAGER=less
export LESS=FRSXi
export EDITOR="${EDITOR:-nano}"
export VISUAL="$EDITOR"
export TEXEDIT="$EDITOR +%d %s"
export DIFFPROG=diff

#export SSH_AUTH_SOCK="${SSH_AUTH_SOCK:-$(gpgconf --list-dirs agent-ssh-socket)}"
export SSH_AUTH_SOCK="${SSH_AUTH_SOCK:-$XDG_RUNTIME_DIR/ssh-agent.socket}"

path () {
    case ":$PATH:" in
        *:"$1":*)
            ;;
        *)
	    PATH="$1${PATH:+:$PATH}"
    esac
}
path ~/bin
export PREFIX_="$HOME"/.local
export CPATH="$PREFIX_/include${CPATH:+:$CPATH}"
export LD_LIBRARY_PATH="$PREFIX_/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export LIBRARY_PATH="$PREFIX_/lib${LIBRARY_PATH:+:$LIBRARY_PATH}"
path "$PREFIX_"/bin
export CARGO_INSTALL_ROOT="$PREFIX_"
path "$CARGO_INSTALL_ROOT"/bin
export GOPATH="$PREFIX_"
path "$GOPATH"/bin
export NPM_CONFIG_PREFIX="$PREFIX_"
path "$NPM_CONFIG_PREFIX"/bin
export PYTHONUSERBASE="$PREFIX_"
path "$PYTHONUSERBASE"/bin
export GEM_HOME="$PREFIX_"
path "$GEM_HOME"/bin
unset path

systemctl --user import-environment
