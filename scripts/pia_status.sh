#!/bin/bash

if [[ $(piactl get connectionstate) = "Connected" ]]; then
	ip=$(piactl get vpnip)
	echo "vpn: $ip"
else
	ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
	echo "public ip: $ip"
fi
