#!/bin/sh

set -ex

echo "debian-live" >/etc/hostname

echo root:3500mt | chpasswd
echo "deb http://deb.debian.org/debian stretch main contrib" >/etc/apt/sources.list.d/contrib.list
export DEBIAN_FRONTEND=noninteractive
apt update
apt install -y live-boot linux-image-amd64 openssh-server debootstrap gdisk dpkg-dev linux-headers-$(uname -r) zfs-dkms

echo "PermitRootLogin yes" >>/etc/ssh/sshd_config
