#!/usr/bin/env bash
set -euo pipefail

# Web browser
# xdg-settings set default-web-browser firefox.desktop
xdg-mime default firefox.desktop x-scheme-handler/http
xdg-mime default firefox.desktop x-scheme-handler/https
xdg-mime default firefox.desktop text/html

# Image viewer
xdg-mime default imv.desktop image/jpeg
xdg-mime default imv.desktop image/png
xdg-mime default imv.desktop image/gif
xdg-mime default imv.desktop image/bmp
xdg-mime default imv.desktop image/svg+xml

# Media player for audio/video
xdg-mime default mpv.desktop video/mp4
xdg-mime default mpv.desktop video/x-matroska
xdg-mime default mpv.desktop audio/mpeg
xdg-mime default mpv.desktop audio/ogg

# PDF viewer
xdg-mime default sioyek.desktop application/pdf

# Email (mailto:)
# Make Thunderbird the handler for mailto: links
xdg-settings set default-url-scheme-handler mailto org.mozilla.Thunderbird.desktop

# File manager for folders
xdg-mime default thunar.desktop inode/directory

# Editor for plain text / source code
xdg-mime default nvim.desktop text/plain

# Optional: register kitty as your default terminal (if your DE honors x-scheme-handler/terminal)
xdg-mime default kitty.desktop x-scheme-handler/terminal

# Verification
echo "Default web browser:    $(xdg-settings get default-web-browser)"
echo "HTTP handler:           $(xdg-mime query default x-scheme-handler/http)"
echo "HTTPS handler:          $(xdg-mime query default x-scheme-handler/https)"
echo "HTML handler:           $(xdg-mime query default text/html)"

echo "Image (JPEG):           $(xdg-mime query default image/jpeg)"
echo "Image (PNG):            $(xdg-mime query default image/png)"
echo "Image (GIF):            $(xdg-mime query default image/gif)"
echo "Image (BMP):            $(xdg-mime query default image/bmp)"
echo "Image (SVG):            $(xdg-mime query default image/svg+xml)"

echo "Video (MP4):            $(xdg-mime query default video/mp4)"
echo "Video (MKV):            $(xdg-mime query default video/x-matroska)"
echo "Audio (MP3):            $(xdg-mime query default audio/mpeg)"
echo "Audio (OGG):            $(xdg-mime query default audio/ogg)"

echo "PDF handler:            $(xdg-mime query default application/pdf)"

echo "Mailto handler (xdg):   $(xdg-mime query default x-scheme-handler/mailto)"
echo "Mailto handler (xdg-settings): $(xdg-settings get default-url-scheme-handler mailto)"

echo "Folder handler:         $(xdg-mime query default inode/directory)"

echo "Text editor:            $(xdg-mime query default text/plain)"

echo "Terminal handler:       $(xdg-mime query default x-scheme-handler/terminal)"
