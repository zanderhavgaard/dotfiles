#!/bin/bash

# update/install krew plugins

PLUGINS="
tree
"

figlet -f slant "krew install"

echo "Installing Krew plugins ..."

for PLUGIN in $PLUGINS ; do
    echo "---"
    echo "Installing $PLUGIN ..."
    kubectl krew install "$PLUGIN"
    echo "---"
done
