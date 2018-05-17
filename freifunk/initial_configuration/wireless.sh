#!/bin/sh
if [ -z $(uci get wireless.radio0) ]; then
	echo "No wifi device found"
fi

radio0_disabled=$(uci get wireless.radio0.disabled)
radio0_default=$(uci get wireless.default_radio0)

if [ "$radio0_disabled" == "1" ] && [ "$radio0_default" == "wifi-iface" ];then
	echo "Disabled adapter with default configuration found - disabling default configuration"
	uci set wireless.default_radio0.disabled='1'
fi

echo "Creating wifi interface on radio0 - Assuming 2.4 Ghz - Using channel 1"
uci -q batch <<EOF
	set wireless.radio0.disabled='0'
	set wireless.radio0.channel='1'                 # Radio settings
        set wireless.radio0.htmode='HT20'
        set wireless.radio0.country='DE'
        set wireless.wifi_freifunk='wifi-iface'         # 1. wifi: Accesspoint
        set wireless.wifi_freifunk.device='radio0'                            
        set wireless.wifi_freifunk.network='freifunk'
        set wireless.wifi_freifunk.mode='ap'            
        set wireless.wifi_freifunk.ssid='Freifunk'                   	

        set wireless.wifi_mesh='wifi-iface'             # 2. wifi: ad-Hoc mesh
        set wireless.wifi_mesh.device='radio0'          
        set wireless.wifi_mesh.network='mesh babel_mesh'
        set wireless.wifi_mesh.mode='adhoc'             
        set wireless.wifi_mesh.ssid='42:42:42:42:42:42' 
        set wireless.wifi_mesh.bssid='42:42:42:42:42:42'
        set wireless.wifi_mesh.mcast_rate='12000'
EOF



radio1=$(uci get wireless.radio1)
if [ $radio1 ];then
	echo "Found 2nd wifi-interface - Assuming 5Ghz - Using channel 36"
	radio1_disabled=$(uci get wireless.radio1.disabled)
	radio1_default=$(uci get wireless.default_radio1)
	
	if [ "$radio1_disabled" == "1" ] && [ "$radio1_default" == "wifi-iface" ];then
        	echo "Disabled adapter with default configuration found - disabling default configuration"
        	uci set wireless.default_radio1.disabled='1'
	fi
	uci -q batch <<EOB
        	set wireless.radio1.disabled='0'
		set wireless.radio1.channel='36'                 # radio settings
        	set wireless.radio1.country='DE'
        	set wireless.radio1.htmode='HT40'
		set wireless.wifi_freifunk5='wifi-iface'         # 1. wifi: accesspoint
        	set wireless.wifi_freifunk5.device='radio1'
        	set wireless.wifi_freifunk5.network='freifunk'
        	set wireless.wifi_freifunk5.mode='ap'
        	set wireless.wifi_freifunk5.ssid='Freifunk'

        	set wireless.wifi_mesh5='wifi-iface'             # 2. wifi: ad-Hoc mesh
        	set wireless.wifi_mesh5.device='radio1'
        	set wireless.wifi_mesh5.network='mesh5 babel_mesh5'
        	set wireless.wifi_mesh5.mode='adhoc'
        	set wireless.wifi_mesh5.ssid='42:42:42:42:42:42'
        	set wireless.wifi_mesh5.bssid='42:42:42:42:42:42'
        	set wireless.wifi_mesh5.mcast_rate='12000'

EOB

fi

uci commit wireless

