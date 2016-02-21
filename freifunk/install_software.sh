#!/bin/sh

PKGS="ip openvpn-polarssl babeld kmod-batman-adv fastd kmod-ebtables ebtables kmod-ebtables-ipv4 owipcalc"

echo "Installing: $PKGS"

opkg update
opkg install $PKGS
