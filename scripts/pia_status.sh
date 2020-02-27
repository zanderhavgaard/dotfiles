#!/bin/bash

if [[ -z $(ifconfig | grep tun0) ]]; then
	echo "ﰸ pia off"
else
	echo "廬"
fi
