#!/bin/sh

PKGS="ip openvpn-polarssl babeld fastd ebtables kmod-ebtables-ipv4 owipcalc batctl haveged kmod-nf-nathelper-extra kmod-pptp ppp-mod-pptp"

echo "Installing: $PKGS"
opkg update
opkg install $PKGS
