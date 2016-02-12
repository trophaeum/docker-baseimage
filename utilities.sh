#!/bin/bash
set -e
source /bd_build/buildconfig
set -x

## Often used tools.
$minimal_apt_get_install curl less vim-nox psmisc wget sudo net-tools ca-certificates unzip lsof strace bind9-host bind9utils openssl-blacklist openssl-blacklist-extra openssh-blacklist openssh-blacklist-extra openvpn-blacklist zsh-static pbzip2 pigz sshfs autossh rsync screen ssl-cert sysstat p7zip-rar p7zip-full p7zip unzip unrar zip rar lzop lrzip advancecomp xz-utils lzma lunzip lzip plzip xzdec zoo zopfli arj upx-ucl jpegoptim optipng pngcrush imagemagick gifsicle geoip-bin geoip-database-contrib
ln -fs /usr/bin/vim.nox /usr/bin/vim

## This tool runs a command as another user and sets $HOME.
cp /bd_build/bin/setuser /sbin/setuser
