#!/bin/sh

# Include libnode helper functions
. ./lib/lib_node.sh
# Gather data from environment

latitude=$(uci get node_config.@position[0].lat)
longitude=$(uci get node_config.@position[0].long)
street=$(uci get node_config.@position[0].street)
city=$(uci get node_config.@position[0].city)
zip=$(uci get node_config.@position[0].zip)

mail=$(uci get node_config.@contact[0].mail)

enabled=$(uci get node_config.@monitoring[0].enabled)

if [ "$enabled" -ne '1' ]; then
    logger "Monitoring is disabled"
    echo "Monitoring is disabled"
    exit 0
fi

# Generating node-info
json="{
  \"nodeinfo\": {
    \"software\": {
      \"batman-adv\": {
        \"version\": \"$(node_batadv_version)\"
      },
      \"fastd\": {
        \"version\": \"$(node_fastd_version)\"
      },
      \"babel\": {
        \"version\": \"$(node_babeld_version)\"
      },
      \"firmware\": {
        \"base\": \"$(node_firmware_base)\",
        \"release\": \"$(node_freifunk_release)\"
      }
    },
    \"location\": {
      \"latitude\": ${latitude},
      \"longitude\": ${longitude},
      \"street\": \"${street}\",
      \"city\": \"${city}\",
      \"zip\": \"${zip}\"
    },
    \"owner\": {
      \"contact\": \"${mail}\"
    },
    \"node_id\": \"$(node_id)\",
    \"hostname\": \"$(node_hostname)\",
    \"hardware\": {
      \"model\": \"$(node_model)\"
    },
    \"network\": {
      \"addresses\": [
        \"$(node_freifunk_ipv4)\",\"$(node_freifunk_ipv6)\"
      ]
    }
  }
}
"
echo "${json}" > /tmp/nodeinfo.json
compressed=$(gzip -c < /tmp/nodeinfo.json)
server=$(uci get node_config.@monitoring[0].server)
while true; do
    echo "Sending to: ${server}"
    echo ${compressed} | nc -u $server 45123
    sleep 60;
done

