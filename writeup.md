# What this does

There are a couple of things that this does so I'll list them all
here.

## User

- dotfiles
- bin scripts
- vm dirs as nocow
- secure gpg dir
- install/update pkgs
  - emacs
  - windows dev box
  - ...
- install user progs
  - thefuck
  - udiskie
  - lesspipe
  - moreutils
  - unzip
  - unrar
  - emacs
  - offlineimap
  - lastpass-cli
  - trash-cli
  - fzf
  - ripgrep
  - bat
  - sshpass
- devtools
  - git, hub, python, python-pip, nodejs, npm, go, rustup, cmake,
	clang, gdb, watchman, vagrant, virtualbox, docker, docker-compose,
	docker-machine,
- other
  - xclip, shellcheck, go-tools, flake8, autopep8, yapf, ipython,
	python-jedi, python-rope, python-virtualenv, prettier, bear,
	gocode-git, aspell, aspell-en

## System Graphics

- lightdm, lightdm-gtk-greeter, accpountsservice
- xorg, xdotool, xclip
- i3-gaps, i3blocks, i3status
- perl-json-xs, perl-anyevent-i3
- compton, feh, dunst, scrot, dex, dmenu

## User Graphics

- redshift, python-xdg
- terminus-font
- arandr
- xterm
- syncthing-gtk
- qbittorrent
- kdeconnect
- network-manager-applet
- chromium, ttf-liberation, noto-fonts, libu2f-host, chromium-widevine
- firefox

## System

- sets up tlp and suspend-then-hibernate with 1 hour
- disable systemd-rfkill
- update mirror list
- pacman hook to keep cache clean
- setup pacman-key
- install kernel headers
- install microcode
- add xyne repo
- setup bauerbill, powerpill, and pacserve
- hostname, console keymap/font, locale, timezone
- periodic fstrim for ssd
- setup main user with sudo and dotfiles
- mark vm directories with nocow
- run install/update user tasks
- update grub config
- install postgres with pam authentication
- setup printer (cups, ghostscript, foomatic-db, sane)
- wheel as printer admin
- setup sshd with key auth only
- admin user setup and lock root
- pcscd smartcard setup with openpgp instead of PIV-II
  - install ccid, opensc, libusb-compat
- setup pkgfile with updates
- setup bluetooth
  - install bluez, bluez-utils, blueman, pulseaudio-bluetooth
- install dev-tools
- setup locate
- setup ecryptfs
- setup system graphics
- configure natural scrolling with touchpad
- caps lock as control (ctrl:nocaps) on keyboard
- install linux-zen for a workstation
- setup network manager
- setup office suite
  - texlive-most, libreoffice-fresh, hunshell-en, evince
- setup audio
  - pulseaudio, pulseaudio-alsa, pavucontrol, pamizer, pasystray
- setup backups
- setup apcupsd
