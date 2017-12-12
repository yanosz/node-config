#!/bin/sh

wan_if=$(uci get network.wan.ifname 2> /dev/null) # Ignore errors => No interface anyway
lan_if=$(uci get network.lan.ifname 2> /dev/null) # Ignore errors => No interface anyway

# Make sure, that fastd is using only lan and wan interfaces to avoid tunnel-in-tunnel situations
if [ $wan_if ];then
	uci add_list fastd.backbone.bind="any:10000 interface \"$wan_if\""
	uci add_list fastd.supernode.bind="any:10001 interface \"$wan_if\""
fi

if [ $lan_if ];then
	uci add_list fastd.backbone.bind="any:10000 interface \"$lan_if\"" 
        uci add_list fastd.supernode.bind="any:10001 interface \"$lan_if\""
fi
uci commit fastd
