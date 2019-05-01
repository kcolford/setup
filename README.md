# System Setup

These are scripts for personal system setup.

## Running

Just run `ansible-pull` on the repo to setup a new system. You require
`lastpass-cli` to be installed as well as git.

Run `ansible-playbook dotfiles.yml` as user to install dotfiles as the
current user and do a number of other initial tasks. Once done, setup
syncthing with phone and install `chromium-widevine` from the AUR.
