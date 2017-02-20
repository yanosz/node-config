#!/bin/sh

PKGS="ip-full openvpn-mbedtls  babeld fastd owipcalc batctl haveged kmod-nf-nathelper-extra kmod-pptp ppp-mod-pptp  ebtables kmod-ebtables-ipv4"

echo "Installing: $PKGS"
opkg update
opkg install $PKGS
