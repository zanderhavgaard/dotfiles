#!/usr/bin/env bash

# unocmment locales in /etc/locale.gen
# sudo sed -i 's/^#en_DK.UTF-8 UTF-8/en_DK.UTF-8 UTF-8/' /etc/locale.gen
# then run:
sudo locale-gen
sudo localectl set-locale LANG=en_DK.UTF-8
