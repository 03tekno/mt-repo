#!/bin/bash

# --- AYARLAR ---
OS_NAME="Debian Lite"
ISO_FILENAME="Debian-Lite"
WORK_DIR="live-build"
DIST="testing"

# Hata oluşursa işlemi durdur
set -e

# Root kontrolü
if [ "$EUID" -ne 0 ]; then 
  echo "HATA: Lütfen bu betiği sudo ile çalıştırın!"
  exit 1
fi

echo "--- [$OS_NAME] Hazırlık: Gerekli paketler kontrol ediliyor ---"
apt update || true
apt install -y live-build debootstrap curl squashfs-tools xorriso debian-archive-keyring

# Eski çalışma alanını temizle
if [ -d "$WORK_DIR" ]; then
    echo "--- Temizlik yapılıyor ---"
    rm -rf "$WORK_DIR"
fi
mkdir "$WORK_DIR" && cd "$WORK_DIR"

echo "--- [$OS_NAME] Yapılandırma Başlıyor (Debian) ---"

lb config \
    --mode debian \
    --system live \
    --distribution $DIST \
    --debian-installer none \
    --compression gzip \
    --apt-recommends true \
    --archive-areas "main contrib non-free non-free-firmware" \
    --security true \
    --updates true \
    --source false \
    --image-name $ISO_FILENAME \
    --bootappend-live "boot=live components locales=tr_TR.UTF-8 keyboard-layouts=tr quiet splash fastboot"

# 5. Paket Listesi
cat <<EOF > config/package-lists/custom.list.chroot
calamares calamares-settings-debian sudo mousepad ristretto cinnamon firmware-linux firmware-linux-nonfree firmware-misc-nonfree firmware-realtek firmware-atheros firmware-amd-graphics plymouth plymouth-themes synaptic
EOF

# --- İNŞA SÜRECİ ---
echo "--- Debian Lite İnşa Ediliyor ---"
lb build

echo "--- İŞLEM BAŞARILI ---"