#!/bin/sh

# ebtables Multicast-Filter - wieder keine UCI-Settings
# Verbiete Multicast (d.h. auch Broadcast) im batman-adv Mesh
# Erlaube DHCP und ARP - Sie werden von batman-adv in unicast umgewandelt
echo "
ebtables -F
ebtables -A FORWARD -p ARP -j ACCEPT
ebtables -A FORWARD -p IPv4 --ip-protocol udp --ip-destination-port 67:68 -j ACCEPT
ebtables -A FORWARD -d Multicast -j DROP


# Hack: https://lists.openwrt.org/pipermail/openwrt-users/2016-March/004150.html
# Da folgende rule nicht via /etc/config/network eingetragen werden kann, 
# erfogt es im Rahmen der firewall

# Pref 66 ist wichtig, da die Rules sonst mit priority 0, d.h. for local
# eingetragen werden
ip rule del iif wlan0 lookup 66 pref 66 || true
ip rule del oif wlan0 lookup 66 pref 66 || true

ip rule add iif wlan0 lookup 66 pref 66
ip rule add oif wlan0 lookup 66 pref 66

ip -6 rule del iif wlan0 lookup 66 pref 66 || true
ip -6 rule del oif wlan0 lookup 66 pref 66 || true

ip -6 rule add iif wlan0 lookup 66 pref 66
ip -6 rule add oif wlan0 lookup 66 pref 66

" >> /etc/firewall.user





