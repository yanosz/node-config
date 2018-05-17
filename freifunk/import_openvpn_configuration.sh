#!/bin/sh

# Das Script kann nur einmal ausgeführt werden
if [ -f /lib/freifunk/config_import_openvpn_done ];then
  echo "Configuration already imported // Konfiguration wurde bereits importiert"
  exit 0
fi
touch /lib/freifunk/config_import_openvpn_done

uci -m import openvpn < /lib/freifunk/initial_configuration/openvpn.uci

# Curser abschliessen
uci commit
