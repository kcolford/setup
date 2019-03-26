. ~/.profile
. ~/.bashrc
if command -v systemctl > /dev/null 2>&1; then
    systemctl --user import-environment PATH
fi

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
