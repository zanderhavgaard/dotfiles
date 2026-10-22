#!/usr/bin/env bash

# NOTE: this script expects to be run from the root of the dotfiles repo

# symlink each file in dotfiles/systemd/user to ~/.config/systemd/user

mkdir -pv "$HOME/.config/systemd/user"

files=$(ls systemd/user)

for file in $files; do
  echo "Symlinking $file ..."
  rm -fv "$HOME/.config/systemd/user/$file"
  ln -sv "$PWD/systemd/user/$file" "$HOME/.config/systemd/user/$file"
done

systemctl --user daemon-reload
systemctl --user enable --now awww-cycle.timer

# shared ssh-agent (provided by openssh); fish/config.fish points SSH_AUTH_SOCK
# at its socket, $XDG_RUNTIME_DIR/ssh-agent.socket
# keys are added to it on first use via AddKeysToAgent in ssh/config
systemctl --user enable --now ssh-agent.socket
