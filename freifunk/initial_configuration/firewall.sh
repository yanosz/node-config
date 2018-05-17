#!/bin/sh

# ebtables Multicast-filter - not exposed to uci
# reject multicast / broadcast within the batman-adv mesh
# allow DHCP and ARP - it is translated into unicast
echo "
ebtables -F
ebtables -A FORWARD -p ARP -j ACCEPT
ebtables -A FORWARD -p IPv4 --ip-protocol udp --ip-destination-port 67:68 -j ACCEPT
ebtables -A FORWARD -d Multicast -j DROP


#" > /etc/firewall.user


