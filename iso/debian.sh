#!/bin/bash

### Kişisel Debian sid/testing ISO yapımı
### sudo ./debian.sh komutu ile çalıştırınız

### gerekli paketler
apt install debootstrap xorriso squashfs-tools mtools grub-pc-bin grub-efi -y

### Chroot oluşturmak için
mkdir kaynak
chown root kaynak

### Testing için
debootstrap --arch=amd64 sid kaynak https://deb.debian.org/debian
# debootstrap --arch=amd64 testing kaynak https://deb.debian.org/debian

### bind bağı için
for i in dev dev/pts proc sys; do mount -o bind /$i kaynak/$i; done

### Depo eklemek için
echo 'deb http://deb.debian.org/debian sid main contrib non-free' > kaynak/etc/apt/sources.list
# echo 'deb http://deb.debian.org/debian testing main contrib non-free' > kaynak/etc/apt/sources.list
chroot kaynak apt update

### kernel paketini kuralım
chroot kaynak apt-get install linux-image-amd64 -y

### grub paketleri için
chroot kaynak apt-get install grub-pc-bin grub-efi-ia32-bin grub-efi -y

### live paketleri için
chroot kaynak apt-get install live-config live-boot -y 

### init paketleri için
chroot kaynak apt-get install xorg xinit lightdm -y

### firmware paketleri için (Burada kendi donanımınıza göre tercih yapabilirsiniz!) 
chroot kaynak apt-get install firmware-linux firmware-linux-free firmware-linux-nonfree firmware-misc-nonfree firmware-amd-graphics firmware-realtek bluez-firmware -y

### Xfce için gerekli paketleri kuralım
chroot kaynak apt-get install xfce4 xfce4-goodies network-manager-gnome papirus-icon-theme firefox firefox-l10n-tr -y

### İsteğe bağlı paketleri kuralım
chroot kaynak apt-get install gvfs-backends inxi wget mintstick deepin-deb-installer gnome-calculator file-roller synaptic -y

### Yazıcı tarayıcı ve bluetooth paketlerini kuralım (isteğe bağlı)
chroot kaynak apt-get install printer-driver-all system-config-printer simple-scan blueman -y

### zorunlu kurulu gelen paketleri silelim (isteğe bağlı)
chroot kaynak apt-get remove xterm termit xarchiver -y

### Zorunlu değil ama grub güncelleyelim
chroot kaynak update-grub
chroot kaynak apt-get upgrade -y

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
echo 'menuentry "Start DEBIAN Unofficial 64-bit" --class debian {' >> isowork/boot/grub/grub.cfg
echo '    linux /live/vmlinuz boot=live live-config live-media-path=/live --' >> isowork/boot/grub/grub.cfg
echo '    initrd /live/initrd.img' >> isowork/boot/grub/grub.cfg
echo '}' >> isowork/boot/grub/grub.cfg

echo "ISO oluşturuluyor.."
grub-mkrescue isowork -o debian-xfce-live-$(date +%x).iso