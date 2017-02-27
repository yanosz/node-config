#!/bin/sh

# ebtables Multicast-Filter - wieder keine UCI-Settings
# Verbiete Multicast (d.h. auch Broadcast) im batman-adv Mesh
# Erlaube DHCP und ARP - Sie werden von batman-adv in unicast umgewandelt
echo "
ebtables -F
ebtables -A FORWARD -p ARP -j ACCEPT
ebtables -A FORWARD -p IPv4 --ip-protocol udp --ip-destination-port 67:68 -j ACCEPT
ebtables -A FORWARD -d Multicast -j DROP


#" > /etc/firewall.user


