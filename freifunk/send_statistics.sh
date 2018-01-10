#!/bin/sh
. ./lib/libnode_json.sh
. ./lib/lib_node.sh

echo "
{
\"statistics\": {
	$(node_json_clients),
	\"node_id\" : \"$(node_id)\",
	$(node_json_meminfo),
	\"uptime\": $(node_uptime),
	\"loadavg\": $(node_load_avg),
	$(node_json_survey),
	\"interfaces\": {
		\"br-freifunk\": $(node_json_freifunk_ifstat)
	}
},
\"neighbours\": {
	$(node_json_bat_neigh),
	$(node_json_wifi_neigh)
	}
}
"
