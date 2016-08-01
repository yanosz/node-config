#!/bin/sh


#Check if platform is already processd
if [ -f "/lib/freifunk/import_feeds_run" ];then
	exit 0;
fi

import_feeds() {
	platform=$1
	echo "Adding feeds for batman-adv ($platform) to /etc/opkg/customfeeds.conf"
	echo "
src/gz chaos_calmer_base_yanosz http://openwrt.yanosz.net/openwrt-15.05.1/$platform/packages/base                              
src/gz chaos_calmer_routing_yanosz http://openwrt.yanosz.net/openwrt-15.05.1/$platform/packages/routing                        
	" >> /etc/opkg/customfeeds.conf
	touch /lib/freifunk/import_feeds_run 
	cp /lib/freifunk/keys/* /etc/opkg/keys
}  

case $(opkg print-architecture) in
  *ar71xx*)
    import_feeds ar71xx
    ;;
  *x86*)
    import_feeds x86
    ;;
  *)
    echo "Fuer Deine Platfrom sind keine Feeds verfuegbar"
    echo "Bitte beachte https://github.com/yanosz/node-config"
    echo $(opkg print-architecture)
    exit 1;
    ;;
esac
