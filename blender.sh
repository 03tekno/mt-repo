#!/bin/bash
## Root olmanız gerekmez ./blender.sh komutunu çalıştırmanız yeterlidir.
## Bu scprit Blender'in 3.2 sürümünü otomatik indirip kurar 

wget -O /tmp/blender.tar.bz2 "https://download.blender.org/release/Blender3.2/blender-3.2.2-linux-x64.tar.xz"
mkdir ~/.local/share/applications
cat >> $HOME/.local/share/applications/Blender.desktop << EOF
[Desktop Entry]
Version=1.0
Name=Blender
Comment=Blender
GenericName=Blender
Exec=$HOME/.local/blender-3.2.2-linux-x64/blender
Terminal=false
Type=Application
Icon=$HOME/.local/blender-3.2.2-linux-x64/blender.svg
Categories=GTK;Graphics
MimeType=application/x-blender;
StartupNotify=true
EOF
tar -xvf /tmp/blender.tar.bz2 -C ~/.local
