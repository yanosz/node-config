#!/bin/sh

PKGS="ip-full openvpn-mbedtls  babeld fastd owipcalc batctl haveged kmod-nf-nathelper-extra kmod-pptp ppp-mod-pptp"

echo "Installing: $PKGS ebtables kmod-ebtables-ipv4"
opkg update
#Ignore errors installing ebtables due to Lede Bug FS#433
opkg install $PKGS
if [ "$?" != "0" ];then
  exit 1
fi
opkg install ebtables kmod-ebtables-ipv4
exit 0;
