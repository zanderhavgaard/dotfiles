#!/usr/bin/env bash

# symlink each directory in the config directory to ~/.config/

configs=$(ls -d */)

ignored_directories="archive scripts wlr-randr xkb"

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
