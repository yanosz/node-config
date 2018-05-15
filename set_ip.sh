#!/bin/sh

# Script zum Aendern der IP-Adressen und Bereiche
# Alle Adressen und Bereiche werden konsistent geaendert

# Konfiguration abfragen

echo -e "\n\n\n\n\n\n"
echo -e "====================================================================================================\n"
echo -e "Please enter a IPv4-Netz for this  node /\nBitte geben sie ein IPv4-Netz fuer diesen Node an (10.23.42.0/24 ../20):"
while true; do
	read ipv4_network
	echo -e "\n\n"
	how_many=$(owipcalc $ipv4_network howmany /32 2> /dev/null)
	if [ "$how_many" -gt "4096" ] || [ "$how_many" -lt "256" ] ; then
		echo "Please use a network with range: / Bitte verwende ein Netz im Bereich: /24, /23, /22, /21, /20"
	elif [ "$(owipcalc $ipv4_network network 2> /dev/null)" == "192.168.1.0" ] ; then
		echo -e "192.168.1.0 is used for management - please enter a different one /\n192.168.1.0 wird zur Verwaltung benoetigt - bitte gib einen anderen Prefix an"
        elif [ "$how_many" -le "4096" ] && [ "$how_many" -ge "256" ] ; then
                break;
	else
		echo "Invalid input - please enter a network / Ungueltige Eingabe - bitte geben Sie ein Netz an (172.16.0.0/24):"
	fi
	
done
echo -e "Please enter an IPv6 network for this node /\nBitte geben sie ein IPv6-Netz fuer diesen Node an (fdd3:5d16:b5dd:f040::/64):"
while true; do
	read ipv6_network
	how_many=$(owipcalc $ipv6_network howmany ::/64 2> /dev/null)
	echo -e "\n\n"
	if [ "$how_many" -ne "1" ] ; then
                echo "Please use a network with range: / Bitte verwende ein Netz im Bereich: /64"
        elif [ "$how_many" -eq "1" ] ;  then
                break;
       	else 
		echo "Invalid input - please enter a network / Ungueltige Eingabe - bitte geben Sie ein Netz an (fdd3:5d16:b5dd:f040::/64):"
	fi
done 

#Basis-Adressen fuer die entspr. Routes ausrechnen
ipv4_addr=$(owipcalc $ipv4_network network add 1)
ipv6_addr=$(owipcalc $ipv6_network add 1 prefix 128)

# Konfiguration setzen
uci -q batch <<EOF
	set network.freifunk.ipaddr='$ipv4_addr'
	set network.freifunk.ip6addr='$ipv6_addr'
	set network.route4_node_subnet.target='$ipv4_network'
	set network.fastd.ipaddr='$ipv4_addr'
	set network.babel_mesh.ipaddr='$ipv4_addr'
	set network.babel_mesh5.ipaddr='$ipv4_addr'

        set network.freifunk.ip6prefix='$ipv6_network'
	set network.route_6_node_subnet.target='$ipv6_network'
	set network.rule_node_ip_high_prio.src='$ipv4_addr/32'

	set network.freifunk.disabled='0'
	set network.fastd.disabled='0'
	set network.babel_mesh.disabled='0'
	set network.babel_mesh5.disabled='0'

	commit network
EOF

