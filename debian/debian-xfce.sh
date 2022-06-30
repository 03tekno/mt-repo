#!/bin/bash

#Gerekli paketlerin kurulması
apt-get install debootstrap xorriso squashfs-tools mtools grub-pc-bin grub-efi devscripts -y

#debian-chroot dosyası oluşturalım
mkdir debian-chroot
chown root debian-chroot
debootstrap --arch=amd64 testing debian-chroot https://deb.debian.org/debian
for i in dev dev/pts proc sys; do mount -o bind /$i debian-chroot/$i; done

#Debian testing depo ekleyelim
echo 'deb https://deb.debian.org/debian testing main contrib non-free' > debian-chroot/etc/apt/sources.list
chroot debian-chroot apt-get update

#Kernel Grub Live Xorg ve Xinit paketleri kuralım
chroot debian-chroot apt-get install linux-image-amd64 -y
chroot debian-chroot apt-get install grub-pc-bin grub-efi-ia32-bin grub-efi -y
chroot debian-chroot apt-get install live-config live-boot -y 
chroot debian-chroot apt-get install xorg xinit -y

#Firmware paketlerini kuralım (Kurulmasını istemediğiniz firmware paketini silebilirsiniz.)
chroot debian-chroot apt-get install atmel-firmware -y
chroot debian-chroot apt-get install bluez-firmware -y
chroot debian-chroot apt-get install dahdi-firmware-nonfree -y
chroot debian-chroot apt-get install firmware-amd-graphics -y
chroot debian-chroot apt-get install firmware-ath9k-htc -y
chroot debian-chroot apt-get install firmware-atheros -y
chroot debian-chroot apt-get install firmware-b43-installer -y
chroot debian-chroot apt-get install firmware-b43legacy-installer -y
chroot debian-chroot apt-get install firmware-bnx2 -y
chroot debian-chroot apt-get install firmware-bnx2x -y
chroot debian-chroot apt-get install firmware-brcm80211 -y
chroot debian-chroot apt-get install firmware-cavium -y
chroot debian-chroot apt-get install firmware-intel-sound -y
chroot debian-chroot apt-get install firmware-intelwimax -y
chroot debian-chroot apt-get install firmware-ipw2x00 -y
chroot debian-chroot apt-get install firmware-ivtv -y
chroot debian-chroot apt-get install firmware-iwlwifi -y
chroot debian-chroot apt-get install firmware-libertas -y
chroot debian-chroot apt-get install firmware-linux -y
chroot debian-chroot apt-get install firmware-linux-free -y
chroot debian-chroot apt-get install firmware-linux-nonfree -y
chroot debian-chroot apt-get install firmware-misc-nonfree -y
chroot debian-chroot apt-get install firmware-myricom -y
chroot debian-chroot apt-get install firmware-netronome -y
chroot debian-chroot apt-get install firmware-netxen -y
chroot debian-chroot apt-get install firmware-qcom-soc -y
chroot debian-chroot apt-get install firmware-qlogic -y
chroot debian-chroot apt-get install firmware-realtek -y
chroot debian-chroot apt-get install firmware-samsung -y
chroot debian-chroot apt-get install firmware-siano -y
chroot debian-chroot apt-get install firmware-sof-signed -y
chroot debian-chroot apt-get install firmware-ti-connectivity -y
chroot debian-chroot apt-get install firmware-zd1211 -y
chroot debian-chroot apt-get install hdmi2usb-fx2-firmware -y
  
chroot debian-chroot apt-get install xfce4 xfce4-goodies parole network-manager-gnome -y
chroot debian-chroot apt-get install blueman gvfs-backends synaptic gdebi firefox-esr firefox-esr-l10n-tr -y
chroot debian-chroot apt-get install printer-driver-all system-config-printer simple-scan -y

#Gereksiz paketleri silelim
chroot debian-chroot apt-get remove xterm -y

#chroot debian-chroot /bin/bash
umount -lf -R debian-chroot/* 2>/dev/null

#Temizlik işlemleri
chroot debian-chroot apt-get autoremove
chroot debian-chroot apt-get clean
rm -f debian-chroot/root/.bash_history
rm -rf debian-chroot/var/lib/apt/lists/*
find debian-chroot/var/log/ -type f | xargs rm -f

#isowork dizini oluşturma ve shfs alma işlemi
mkdir isowork
mksquashfs debian-chroot filesystem.squashfs -comp gzip -wildcards
mkdir -p isowork/live
mv filesystem.squashfs isowork/live/filesystem.squashfs
cp -pf debian-chroot/boot/initrd.img* isowork/live/initrd.img
cp -pf debian-chroot/boot/vmlinuz* isowork/live/vmlinuz

#iso taslağı oluşturma
mkdir -p isowork/boot/grub/
echo 'insmod all_video' > isowork/boot/grub/grub.cfg
echo 'menuentry "Start Debian Unofficial 64-bit" --class debian {' >> isowork/boot/grub/grub.cfg
echo '    linux /live/vmlinuz boot=live live-config live-media-path=/live --' >> isowork/boot/grub/grub.cfg
echo '    initrd /live/initrd.img' >> isowork/boot/grub/grub.cfg
echo '}' >> isowork/boot/grub/grub.cfg

echo "----------------İso oluşturuluyor..-----------------"
grub-mkrescue isowork -o debian-live-$(date +%x).iso
