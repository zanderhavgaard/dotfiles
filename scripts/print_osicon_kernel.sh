#!/bin/bash

[[ $(uname -r) =~ ([0-9]+\.[0-9]+\.[0-9]+[\-0-9]*[\-lts]*) ]]

# echo "  ${BASH_REMATCH[1]}"
echo "${BASH_REMATCH[1]} "
