#!/bin/sh

export NAME="Kieran Colford"
export EMAIL="kieran@kcolford.com"

export PATH=/usr/lib/ccache/bin:"$PATH"
export MAKEFLAGS="-j$(nproc)"

export EDITOR=nano

if [ -x /usr/bin/emacs ]; then
    export ALTERNATE_EDITOR="emacs -Q"
    export VISUAL="emacsclient -nw"
    export EDITOR="emacsclient -nw"
fi

export PAGER=less
export LESS=FRSXi
export EDITOR="$EDITOR"
export TEXEDIT="$EDITOR +%d %s"

export DIFFPROG=diff

#export SSH_AUTH_SOCK="${SSH_AUTH_SOCK:-$(gpgconf --list-dirs agent-ssh-socket)}"
export SSH_AUTH_SOCK="${SSH_AUTH_SOCK:-$XDG_RUNTIME_DIR/ssh-agent.socket}"

export PREFIX_="$HOME"/.local
export CPATH="$PREFIX_/include${CPATH:+:$CPATH}"
export CARGO_INSTALL_ROOT="$PREFIX_"
export GOPATH="$PREFIX_${GOPATH:+:$GOPATH}"
export LD_LIBRARY_PATH="$PREFIX_/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export LIBRARY_PATH="$PREFIX_/lib${LIBRARY_PATH:+:$LIBRARY_PATH}"
export PATH="$PREFIX_/bin${PATH:+:$PATH}"
export NPM_CONFIG_PREFIX="$PREFIX_"
export PYTHONUSERBASE="$PREFIX_"
export GEM_HOME="$PREFIX_"

systemctl --user import-environment
