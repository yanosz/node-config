#!/bin/sh

# Script zum Aendern der IP-Adressen und Bereiche
# Alle Adressen und Bereiche werden konsistent geaendert

# Konfiguration abfragen
echo "IP-Adresse konsistent aendern"
echo "IPv4 Adresse des Nodes - z.B. 10.159.64.1"
read ipv4_addr
echo "IPv4 netmask des Nodes - z.B. 255.255.255.0"
read ipv4_mask
echo ""
echo "IPv6-ULA-Adresse des Nodes (CIDR) - z.B. fdd3:5d16:b5dd:f040::1/64"
read ipv6_address
echo "IPv6-ULA-Netz des Nodes (CIDR) - z.B. fdd3:5d16:b5dd:f040::/64"
read ipv6_network
echo "IPv6 ULA-Range der Freifunk-Community - z.B. fdd3:5d16:b5dd::/48 (bei KBU)"
read ipv6_network_community


# Konfiguration setzen
uci set network.freifunk.ipaddr=$ipv4_addr
uci set network.@route[0].target=$ipv4_addr
uci set network.fastd.ipaddr=$ipv4_addr
uci set network.freifunk.netmask=$ipv4_mask
uci set network.@route[0].netmask=$ipv4_mask
uci set network.freifunk.ip6prefix=$ipv6_network
uci set network.kbu_range_v6.dest=$ipv6_network_community
uci set network.@route6[0].target=$ipv6_network

uci commit network
/etc/init.d/network restart
