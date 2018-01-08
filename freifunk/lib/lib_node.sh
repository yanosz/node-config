#!/bin/sh

# MAC address as printed on the sticker
node_mac(){
	local ifnum=$(_wifi_ifnum)
	if [ "$ifnum" -eq "0" ]; then
		echo _mac_address "eth0"
	elif [ "$ifnum" -eq "2" ]; then
		echo $(_mac_address "wlan1")
	else
		echo $(_mac_address "wlan0")
	fi
}

# nodeid derived from mac-adress
node_id(){
	node_mac | sed s/://g
}


# What is the batman-adv version?
node_batadv_version(){
	cat /sys/module/batman_adv/version
}

# What is the babeld version?
node_babeld_version(){
	babeld -V 2>&1
}

# What is the fastd-version?
node_fastd_version(){
	fastd -v
}

# Nice description of the firmware release
node_firmware_base(){
	ubus call system board | jsonfilter -e '@.release.description'
}

# Action Freifunk Firmware version
node_freifunk_release(){
	cat /lib/freifunk/release
}

# Hostname (UCI)
node_hostname(){
	uci get system.@system[0].hostname
}

# Model (ubus)
node_model(){
	ubus call system board | jsonfilter -e '@.model'
}

# All uci network devices in Freifunk-Zone (actual Freifunk Interfaces)
node_freifunk_interfaces(){
	uci get firewall.freifunk.network
}

#IPv4-Address in freifunk-network
node_freifunk_ipv4(){
	uci get network.freifunk.ipaddr
}

#IPv5-Address in freifunk-network
node_freifunk_ipv6(){
	uci get network.freifunk.ip6addr
}

# batman-adv interfaces
node_bat0_wifi_ifs(){
	for interf in `batctl if | cut -f1 -d ':'`; do
		details=$(iw dev $interf info 2> /dev/null)
		if [ ! -z "$details" ]; then
			echo $interf
		fi
	done
}

node_bat0_wired_ifs(){
	for interf in `batctl if | cut -f1 -d ':'`; do                                                 
                details=$(iw dev $interf info 2> /dev/null)                                            
                if [ -z "$details" ]; then                                                           
                        echo $interf                                                                   
                fi                                                                                     
        done  
}

# get mac-address from device (private function)
_mac_address(){
	ifconfig $1 | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}' | awk '{print tolower($0)}'
}

# How many wifi interfaces are connected? (private function)
_wifi_ifnum(){
  echo $(iw phy | grep Wiphy | wc -l)
}

