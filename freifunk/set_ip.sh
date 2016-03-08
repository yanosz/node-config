#!/bin/sh

# Script zum Aendern der IP-Adressen und Bereiche
# Alle Adressen und Bereiche werden konsistent geaendert

# Konfiguration abfragen
echo "IPv4 Adresse des Nodes - z.B. 10.159.64.1"
read ipv4_addr
echo "IPv4 netmask des Nodes - z.B. 255.255.255.0"
read ipv4_mask
echo ""
echo "IPv6-ULA-Netz des Nodes (CIDR) - z.B. fdd3:5d16:b5dd:f040::/64"
read ipv6_network

#Basis-Adressen fuer die entspr. Routes ausrechnen
ipv4_network=$(owipcalc $ipv4_addr/$ipv4_mask network)
ipv6_network_community=$(owipcalc $ipv6_network prev 48 network)


# Konfiguration setzen
uci -q batch <<EOF
	set network.freifunk.ipaddr='$ipv4_addr'
	set network.@route[0].target='$ipv4_network'
	set network.fastd.ipaddr='$ipv4_addr'
	set network.babel_mesh.ipaddr='$ipv4_addr'
	set network.freifunk.netmask='$ipv4_mask'
	set network.@route[0].netmask='$ipv4_mask'
	set network.freifunk.ip6prefix='$ipv6_network'
	set network.kbu_range_v6.dest='$ipv6_network_community'
	set network.@route6[0].target='$ipv6_network'
	commit network
EOF

