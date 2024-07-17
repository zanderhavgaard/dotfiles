#!/bin/bash

OS_NAME="$(rg '^NAME=' /etc/os-release)"

if [[ $OS_NAME == *"Arch"* ]]; then
	OS_ICON=" "
elif [[ $OS_NAME == *"Manjaro"* ]]; then
	OS_ICON=" "
fi

# TODO fix showing if LTS and arch / manjaro
[[ $(uname -r) =~ ([0-9]+\.[0-9]+\.[0-9]+) ]]

echo "$OS_ICON ${BASH_REMATCH[1]}"
