#!/bin/bash
set -e
source /bd_build/buildconfig
set -x

## Temporarily disable dpkg fsync to make building faster.
if [[ ! -e /etc/dpkg/dpkg.cfg.d/docker-apt-speedup ]]; then
	echo force-unsafe-io > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup
fi

echo 'APT::Install-Recommends 0;' >> /etc/apt/apt.conf.d/01norecommends
echo 'APT::Install-Suggests 0;' >> /etc/apt/apt.conf.d/01norecommends

## Prevent initramfs updates from trying to run grub and lilo.
## https://journal.paul.querna.org/articles/2013/10/15/docker-ubuntu-on-rackspace/
## http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=594189
export INITRD=no
mkdir -p /etc/container_environment
echo -n no > /etc/container_environment/INITRD

# Add apt keys we need
APT_KEYS="58118E89F3A912897C070ADBF76221572C52609D A6A19B38D3D831EF 8771ADB0816950D8 3EFF4F272FB2CD80 15CF4D18AF4F7421 EBFF6B99D9B78493 0xcbcb082a1bb943db 7FCC7D46ACCC4CF8 67ECE5605BCF1346 74A941BA219EC810"
for i in ${APT_KEYS}; do
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ${i}
done
apt-get update

## Install HTTPS support for APT.
$minimal_apt_get_install avahi-utils apt-transport-https ca-certificates

# Turn https repo's back on
#sed -i 's/^#\s*\(deb https.*\)$/\1/g' /etc/apt/sources.list

# Get the real list of packages now
apt-get update

## Fix some issues with APT packages.
## See https://github.com/dotcloud/docker/issues/1024
dpkg-divert --local --rename --add /sbin/initctl
ln -sf /bin/true /sbin/initctl

## Replace the 'ischroot' tool to make it always return true.
## Prevent initscripts updates from breaking /dev/shm.
## https://journal.paul.querna.org/articles/2013/10/15/docker-ubuntu-on-rackspace/
## https://bugs.launchpad.net/launchpad/+bug/974584
dpkg-divert --local --rename --add /usr/bin/ischroot
ln -sf /bin/true /usr/bin/ischroot

## Install add-apt-repository
$minimal_apt_get_install software-properties-common

## Upgrade all packages.
apt-get dist-upgrade -y

## Fix locale.
$minimal_apt_get_install language-pack-en
locale-gen en_US
update-locale LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8
echo -n en_US.UTF-8 > /etc/container_environment/LANG
echo -n en_US.UTF-8 > /etc/container_environment/LC_CTYPE
