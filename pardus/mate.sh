#!/bin/bash

### Kişisel Pardus 21 backpots ISO yapımı
### sudo ./mate.sh komutu ile çalıştırınız

### gerekli paketler
apt install debootstrap xorriso squashfs-tools mtools grub-pc-bin grub-efi

### Chroot oluşturmak için
mkdir kaynak
chown root kaynak

### pardus için
debootstrap --arch=amd64 yirmibir kaynak http://depo.pardus.org.tr/pardus

### bind bağı için
for i in dev dev/pts proc sys; do mount -o bind /$i kaynak/$i; done

### depo eklemek için
echo '### The Official Pardus Package Repositories ###' > kaynak/etc/apt/sources.list
echo 'deb http://depo.pardus.org.tr/pardus yirmibir main contrib non-free' >> kaynak/etc/apt/sources.list
echo '# deb-src http://depo.pardus.org.tr/pardus yirmibir main contrib non-free' >> kaynak/etc/apt/sources.list
echo 'deb http://depo.pardus.org.tr/guvenlik yirmibir main contrib non-free' >> kaynak/etc/apt/sources.list
echo '# deb-src http://depo.pardus.org.tr/guvenlik yirmibir main contrib non-free' >> kaynak/etc/apt/sources.list
echo 'deb http://depo.pardus.org.tr/backports yirmibir-backports main contrib non-free' > kaynak/etc/apt/sources.list.d/yirmibir-backports.list
chroot kaynak apt update

### kernel paketini kuralım (Backpots istemiyorsanız -t yirmibir-backports yazısını siliniz!)
chroot kaynak apt-get install -t yirmibir-backports linux-image-amd64 -y

### grub paketleri için
chroot kaynak apt-get install grub-pc-bin grub-efi-ia32-bin grub-efi -y

### live paketleri için
chroot kaynak apt-get install live-config live-boot -y 

### init paketleri için
chroot kaynak apt-get install xorg xinit -y

### firmware paketleri için
chroot kaynak apt-get install -y atmel-firmware bluez-firmware dahdi-firmware-nonfree \
  firmware-amd-graphics firmware-ath9k-htc firmware-atheros \
  firmware-b43-installer firmware-b43legacy-installer firmware-bnx2 \
  firmware-bnx2x firmware-brcm80211 firmware-cavium \
  firmware-intel-sound firmware-intelwimax firmware-ipw2x00 \
  firmware-ivtv firmware-iwlwifi firmware-libertas \
  firmware-linux firmware-linux-free firmware-linux-nonfree \
  firmware-misc-nonfree firmware-myricom firmware-netronome \
  firmware-netxen firmware-qcom-soc firmware-qlogic \
  firmware-realtek firmware-samsung firmware-siano \
  firmware-sof-signed firmware-ti-connectivity firmware-zd1211 hdmi2usb-fx2-firmware
  
### Cinnamon için gerekli paketleri kuralım 
chroot kaynak apt-get install lightdm mate-desktop-environment-extras network-manager-gnome -y

### İsteğe bağlı paketleri kuralım
chroot kaynak apt-get install blueman gvfs-backends neofetch rar -y

### Pardus paketleri kuralım 
chroot kaynak apt-get install pardus-common-desktop pardus-configure pardus-locales -y
chroot kaynak apt-get install pardus-package-installer pardus-software pardus-welcome -y
chroot kaynak apt-get install pardus-dolunay-grub-theme pardus-gtk-theme pardus-icon-theme pardus-about pardus-installer -y

### zorunlu kurulu gelen paketleri silelim (isteğe bağlı)
chroot kaynak apt-get remove xterm icedtea-netx -y

### Zorunlu değil ama grub güncelleyelim
chroot kaynak update-grub

umount -lf -R kaynak/* 2>/dev/null

### temizlik işlemleri
chroot kaynak apt autoremove
chroot kaynak apt clean
rm -f kaynak/root/.bash_history
rm -rf kaynak/var/lib/apt/lists/*
find kaynak/var/log/ -type f | xargs rm -f

### isowork filesystem.squashfs oluşturmak için
mkdir isowork
mksquashfs kaynak filesystem.squashfs -comp gzip -wildcards
mkdir -p isowork/live
mv filesystem.squashfs isowork/live/filesystem.squashfs

cp -pf kaynak/boot/initrd.img* isowork/live/initrd.img
cp -pf kaynak/boot/vmlinuz* isowork/live/vmlinuz

### grub işlemleri 
mkdir -p isowork/boot/grub/
echo 'insmod all_video' > isowork/boot/grub/grub.cfg
echo 'menuentry "Start PARDUS Unofficial 64-bit" --class debian {' >> isowork/boot/grub/grub.cfg
echo '    linux /live/vmlinuz boot=live live-config live-media-path=/live --' >> isowork/boot/grub/grub.cfg
echo '    initrd /live/initrd.img' >> isowork/boot/grub/grub.cfg
echo '}' >> isowork/boot/grub/grub.cfg

echo "ISO oluşturuluyor.."
grub-mkrescue isowork -o pardus-mate-live-$(date +%x).iso
