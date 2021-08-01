#!/bin/bash

# TODO fix showing if LTS and arch / manjaro
[[ $(uname -r) =~ ([0-9]+\.[0-9]+\.[0-9]+) ]]

# echo "  ${BASH_REMATCH[1]}"
echo "${BASH_REMATCH[1]} "
