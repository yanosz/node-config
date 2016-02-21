#!/bin/sh

# Importiere vorhandene Konfiguration
# Firwall und ebtables haben eine Sonderrolle: 
# Die Konfiguration kann nicht einfach per uci merged werden und wird per Script aufgenommen
/lib/freifunk/initial_configuration/ebtables.sh
/lib/freifunk/initial_configuration/wireless.sh


## Weitere Konfigurationen werden via uci import eingelesen und aufgenommen:
# firewall, dhcp, network und wireless ergänzen die vorhandene Konfiguration (-m)
# Bei allen anderen Paketen wird die vorhandene Konfiguration ersetzt
uci import firewall -m 	< /lib/freifunk/initial_configuration/firewall.uci
uci import network 	-m 	< /lib/freifunk/initial_configuration/network.uci
uci import dhcp 	-m	< /lib/freifunk/initial_configuration/dhcp.uci
uci import openvpn  -m 	< /lib/freifunk/initial_configuration/openvpn.uci

uci import babeld 		< /lib/freifunk/initial_configuration/babeld.uci
uci import batman-adv 	< /lib/freifunk/initial_configuration/batman-adv.uci
uci import fastd 		< /lib/freifunk/initial_configuration/fastd.uci

# Curser abschliessen
uci commit

