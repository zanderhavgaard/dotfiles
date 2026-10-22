#!/usr/bin/env bash

# symlink each directory in the config directory to ~/.config/

configs=$(ls -d */)

ignored_directories="archive scripts wlr-randr xkb systemd applications ssh"

for config in $configs; do
  # if config is in ignroed_directories, skip it
  config_name="${config%/}"
  if [[ " $ignored_directories " =~ " $config_name " ]]; then
    echo "Ignored $config_name"
    continue
  fi

  echo "Symlinking $config_name ..."
  rm -rfv "$HOME/.config/$config_name"
  ln -sv "$PWD/$config_name" "$HOME/.config/$config_name"
done

echo "Symlinking claude themes dir ..."
rm -rfv "$HOME/.claude/themes"
ln -sv "$HOME/dotfiles/claude/themes" "$HOME/.claude/themes"

# just the config file: ~/.ssh also holds keys and known_hosts.
# machine-specific hosts go in ~/.ssh/config.local, which ssh/config includes
echo "Symlinking ssh config ..."
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
ln -sfv "$PWD/ssh/config" "$HOME/.ssh/config"

# per-file, since ~/.local/share/applications also holds entries installed by other apps
echo "Symlinking desktop entry overrides ..."
mkdir -p "$HOME/.local/share/applications"
for entry in "$PWD"/applications/*.desktop; do
  ln -sfv "$entry" "$HOME/.local/share/applications/$(basename "$entry")"
done
