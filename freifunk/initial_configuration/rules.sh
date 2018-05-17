mv /etc/rc.local /tmp/rc.local

echo "
#!/bin/sh

# Hack: https://lists.openwrt.org/pipermail/openwrt-users/2016-March/004150.html
# Since /etc/config/network cannot be used for intering rules, the firewall script is used

# Pref 66 is important. It prevents rules with priority 0 (for local)

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

