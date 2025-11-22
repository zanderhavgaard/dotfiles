#!/usr/bin/env bash

# NOTE: this script expects to be run from the root of the dotfiles repo

# symlink each file in dotfiles/systemd/user to ~/.config/systemd/user

files=$(ls systemd/user)

for file in $files; do
  echo "Symlinking $file ..."
  rm -fv "$HOME/.config/systemd/user/$file"
  ln -sv "$PWD/systemd/user/$file" "$HOME/.config/systemd/user/$file"
done

systemctl --user daemon-reload
systemctl --user enable --now swww-cycle.timer
