#!/bin/sh

wget -O /tmp/firefox.tar.bz2 "https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=tr"
mkdir ~/.local/share/applications
cat >> $HOME/.local/share/applications/Firefox-portable.desktop << EOF
[Desktop Entry]
Type=Application
Name=Firefox Portable
Comment=Firefox Portable
Exec=$HOME/.local/firefox/firefox
Icon=$HOME/.local/firefox/browser/chrome/icons/default/default128.png
Categories=Network;
Categories=GNOME;GTK;Network;WebBrowser;
MimeType=application/xhtml+xml;text/xml;application/xhtml+xml;application/vnd.mozilla.xul+xml;text/mml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=false
Terminal=false
EOF
tar -xvf /tmp/firefox.tar.bz2 -C ~/.local