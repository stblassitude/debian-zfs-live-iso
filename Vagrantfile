Vagrant.configure("2") do |config|
  config.vm.box = "debian/stretch64"
  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 2
  end
  config.vm.provision "shell", inline: <<-SHELL
    set -ex
    apt-get update
    export DEBIAN_FRONTEND=noninteractive

    apt-get install -y debootstrap xorriso grub-pc squashfs-tools
    if [ ! -f /livecd/chroot/bin/sh]; then
      debootstrap --arch=amd64 --variant=minbase \
        --include=systemd,systemd-sysv,live-boot,linux-image-amd64,openssh-server,debootstrap,gdisk,dpkg-dev,linux-headers-$(uname -r),iproute2  \
        stretch /livecd/chroot http://deb.debian.org/debian

      mkdir -p /livecd/chroot/root
      cp /vagrant/build-inside-chroot.sh /livecd/chroot/root
      chmod +x /livecd/chroot/root/build-inside-chroot.sh
      mount --rbind /dev  /livecd/chroot/dev
      mount --rbind /proc /livecd/chroot/proc
      mount --rbind /sys  /livecd/chroot/sys
      chroot /livecd/chroot /root/build-inside-chroot.sh
      umount -lR /livecd/chroot/dev  || true
      umount -lR /livecd/chroot/proc || true
      umount -lR /livecd/chroot/sys  || true
    fi

    mkdir -p /livecd/scratch /livecd/image/live
    mksquashfs /livecd/chroot /livecd/image/live/filesystem.squashfs -e boot
    cp /livecd/chroot/boot/vmlinuz-* /livecd/image/vmlinuz
    cp /livecd/chroot/boot/initrd.img-* /livecd/image/initrd
    cat >>/livecd/scratch/grub.cfg <<EOF
search --set=root --file /DEBIAN_CUSTOM

set default="0"
set timeout=30

menuentry "Debian Live" {
  linux /vmlinuz boot=live
  initrd /initrd
}
EOF
    touch /livecd/image/DEBIAN_CUSTOM

    grub-mkstandalone \
      --format=i386-pc \
      --output=/livecd/scratch/core.img \
      --install-modules="linux normal iso9660 biosdisk memdisk search tar ls" \
      --modules="linux normal iso9660 biosdisk search" \
      --locales="" \
      --fonts="" \
      "boot/grub/grub.cfg=/livecd/scratch/grub.cfg"
    cat \
      /usr/lib/grub/i386-pc/cdboot.img \
      /livecd/scratch/core.img \
      > /livecd/scratch/bios.img
    xorriso \
        -as mkisofs \
        -iso-level 3 \
        -full-iso9660-filenames \
        -volid "DEBIAN_CUSTOM" \
        --grub2-boot-info \
        --grub2-mbr /usr/lib/grub/i386-pc/boot_hybrid.img \
        -eltorito-boot \
            boot/grub/bios.img \
            -no-emul-boot \
            -boot-load-size 4 \
            -boot-info-table \
            --eltorito-catalog boot/grub/boot.cat \
        -output "/vagrant/debian-custom.iso" \
        -graft-points \
            "/livecd/image" \
            /boot/grub/bios.img=/livecd/scratch/bios.img
  SHELL
end
