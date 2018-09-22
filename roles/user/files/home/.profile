#!/bin/sh

export NAME="$(getent passwd "$USER" | cut -d : -f 5 | cut -d , -f 1)"
export NAME="$(git config user.name)"
export EMAIL="${USER}@$(hostname --domain)"
export EMAIL="$(git config user.email)"

export PATH=/usr/lib/ccache/bin:"$PATH"
export MAKEFLAGS="-j$(nproc)"

export ALTERNATE_EDITOR="emacs -Q"
export VISUAL="emacsclient -c"
export EDITOR="emacsclient -nw"

export PAGER=less
export LESS=FRSXi
export EDITOR="${EDITOR:-nano}"
export TEXEDIT="${VISUAL:-$EDITOR} +%d %s"

export DIFFPROG=diff

export SSH_AUTH_SOCK="${SSH_AUTH_SOCK:-$(gpgconf --list-dirs agent-ssh-socket)}"

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
