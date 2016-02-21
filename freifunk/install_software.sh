#!/bin/sh

PKGS="ip openvpn-polarssl babeld fastd ebtables kmod-ebtables-ipv4 owipcalc batctl haveged"

echo "Installing: $PKGS"
opkg update
opkg install $PKGS
