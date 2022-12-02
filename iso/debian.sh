#!/bin/bash

### Kişisel Pardus 21 backpots ISO yapımı
### sudo ./pardus.sh komutu ile çalıştırınız

### gerekli paketler
apt install debootstrap xorriso squashfs-tools mtools grub-pc-bin grub-efi -y

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

### firmware paketleri için (Burada kendi donanımınıza göre tercih yapabilirsiniz!) 
chroot kaynak apt-get install firmware-linux -y
chroot kaynak apt-get install firmware-linux-free -y
chroot kaynak apt-get install firmware-linux-nonfree -y
chroot kaynak apt-get install firmware-amd-graphics -y
chroot kaynak apt-get install atmel-firmware -y
chroot kaynak apt-get install bluez-firmware -y
chroot kaynak apt-get install dahdi-firmware-nonfree -y
chroot kaynak apt-get install firmware-ath9k-htc -y
chroot kaynak apt-get install firmware-atheros -y
chroot kaynak apt-get install firmware-b43-installer -y
chroot kaynak apt-get install firmware-b43legacy-installer -y
chroot kaynak apt-get install firmware-bnx2 -y
chroot kaynak apt-get install firmware-bnx2x -y
chroot kaynak apt-get install firmware-brcm80211 -y
chroot kaynak apt-get install firmware-cavium -y
chroot kaynak apt-get install firmware-intel-sound -y
chroot kaynak apt-get install firmware-intelwimax -y
chroot kaynak apt-get install firmware-ipw2x00 -y
chroot kaynak apt-get install firmware-ivtv -y
chroot kaynak apt-get install firmware-iwlwifi -y
chroot kaynak apt-get install firmware-libertas -y
chroot kaynak apt-get install firmware-misc-nonfree -y
chroot kaynak apt-get install firmware-myricom -y
chroot kaynak apt-get install firmware-netronome -y
chroot kaynak apt-get install firmware-netxen -y
chroot kaynak apt-get install firmware-qcom-soc -y
chroot kaynak apt-get install firmware-qlogic -y
chroot kaynak apt-get install firmware-realtek -y
chroot kaynak apt-get install firmware-samsung -y
chroot kaynak apt-get install firmware-siano -y
chroot kaynak apt-get install firmware-sof-signed -y
chroot kaynak apt-get install firmware-ti-connectivity -y
chroot kaynak apt-get install firmware-zd1211 -y
chroot kaynak apt-get install hdmi2usb-fx2-firmware -y

### Xfce için gerekli paketleri kuralım
chroot kaynak apt-get install xfce4 xfce4-goodies network-manager-gnome -y

### İsteğe bağlı paketleri kuralım
chroot kaynak apt-get install gvfs-backends inxi gnome-calculator file-roller synaptic rar -y

### Pardus paketleri kuralım 
chroot kaynak apt-get install pardus-common-desktop pardus-configure pardus-xfce-settings pardus-locales pardus-installer -y
chroot kaynak apt-get install pardus-package-installer pardus-software -y
chroot kaynak apt-get install pardus-dolunay-grub-theme pardus-gtk-theme pardus-icon-theme pardus-backgrounds pardus-about -y

### Yazıcı tarayıcı ve bluetooth paketlerini kuralım (isteğe bağlı)
chroot kaynak apt-get install printer-driver-all system-config-printer simple-scan blueman -y

### zorunlu kurulu gelen paketleri silelim (isteğe bağlı)
chroot kaynak apt-get remove xterm termit xarchiver icedtea-netx -y

### Zorunlu değil ama grub güncelleyelim
chroot kaynak update-grub
chroot kaynak apt upgrade -y
chroot kaynak apt -t yirmibir-backports upgrade -y

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
echo 'menuentry "Start PARDUS Backports Unofficial 64-bit" --class debian {' >> isowork/boot/grub/grub.cfg
echo '    linux /live/vmlinuz boot=live live-config live-media-path=/live --' >> isowork/boot/grub/grub.cfg
echo '    initrd /live/initrd.img' >> isowork/boot/grub/grub.cfg
echo '}' >> isowork/boot/grub/grub.cfg

echo "ISO oluşturuluyor.."
grub-mkrescue isowork -o pardus-xfce-live-$(date +%x).iso
