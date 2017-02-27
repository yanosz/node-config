mv /etc/rc.local /tmp/rc.local

echo "
#!/bin/sh

# Hack: https://lists.openwrt.org/pipermail/openwrt-users/2016-March/004150.html
# Da folgende rule nicht via /etc/config/network eingetragen werden kann, 
# erfogt es im Rahmen der firewall

# Pref 66 ist wichtig, da die Rules sonst mit priority 0, d.h. for local
# eingetragen werden

ip rule del iif wlan0 lookup 66 pref 66 || true
ip rule del oif wlan0 lookup 66 pref 66 || true
ip rule del iif wlan1 lookup 66 pref 66 || true
ip rule del oif wlan1 lookup 66 pref 66 || true
ip rule del iif tap-icvpn lookup 66 pref 66 || true
ip rule del oif tap-icvpn lookup 66 pref 66 || true


ip rule add iif wlan0 lookup 66 pref 66
ip rule add oif wlan0 lookup 66 pref 66
ip rule add iif wlan1 lookup 66 pref 66
ip rule add oif wlan1 lookup 66 pref 66
ip rule add iif tap-icvpn lookup 66 pref 66
ip rule add oif tap-icvpn lookup 66 pref 66 

ip -6 rule del iif wlan0 lookup 66 pref 66 || true
ip -6 rule del oif wlan0 lookup 66 pref 66 || true
ip -6 rule del iif wlan1 lookup 66 pref 66 || true
ip -6 rule del oif wlan1 lookup 66 pref 66 || true
ip -6 rule del iif tap-icvpn lookup 66 pref 66 || true
ip -6 rule del oif tap-icvpn lookup 66 pref 66 || true


ip -6 rule add iif wlan0 lookup 66 pref 66
ip -6 rule add oif wlan0 lookup 66 pref 66
ip -6 rule add iif tap-icvpn lookup 66 pref 66
ip -6 rule add oif tap-icvpn lookup 66 pref 66

ip -6 rule add iif wlan1 lookup 66 pref 66
ip -6 rule add oif wlan1 lookup 66 pref 66
ip -6 rule add iif tap-icvpn lookup 66 pref 66
ip -6 rule add oif tap-icvpn lookup 66 pref 66

" > /etc/rc.local
chmod 755 /etc/rc.local
cat /tmp/rc.local >> /etc/rc.local

