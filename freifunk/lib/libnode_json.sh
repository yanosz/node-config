#!/bin/sh
# Neighbors of batman-adv
#"batadv": {
#      "aa:4b:8b:51:2b:0f": {
#        "neighbours": {
#          "02:ab:ff:a5:1d:03": {
#            "tq": 255,
#            "lastseen": 4.290
#          }
#        }
#      }
node_json_bat_neigh() {
        echo '"batadv": {'
        batctl o | awk '{
        # [B.A.T.M.A.N. adv 2016.5, MainIF/MAC: wlan0/10:fe:ed:ba:d4:b4 (bat0/0e:3f:08:fd:0c:20 BATMAN_IV)]
        if(match($6,/bat0/)) {
                interface=$6;
                sub(/\(bat0\//,"",interface);
                printf("\t\"%s\": {\n",interface);
        }
        #  * 02:ab:ff:a5:1d:03    1.860s   (255) 02:ab:ff:a5:1d:03 [   tap-kbu]
        originator=$2;
        last_seen=$3;
        beacons=$4;
        nexthop=$5;
        if(originator == nexthop){
                if(cnt > 0) {
                        print ",";
                }
                cnt++;
                gsub(/[\(\)]/,"",beacons);
                sub(/s/,"",last_seen);
                tq = 0;
                if (beacons > 0) {
                        tq = 255.0 / beacons;
                }
                printf("\t\t\"%s\" : { \"tq\":%f, \"lastseen\":%s }\n",originator,tq,last_seen);
        }
    }'
    echo -e "\t}\n }"
}

node_json_meminfo(){
  echo "\"memory\": {"
  cat /proc/meminfo | head -n5 | awk -e '{
    if(cnt > 0 ) {
      print ", "
    }
    sub(/MemTotal/,"total",$1);
    sub(/MemFree/,"free",$1);
    sub(/MemAvailable/,"available",$1),
    sub(/Buffers/,"buffers",$1);
    sub(/Cached/, "cached",$1);
    gsub(/\W/,"",$1);
    gsub(/\W/,"",$2);
    printf("\t\t\"%s\": %s",$1,$2);
    cnt=1;
  }'
  echo -e "\t}"
}

#"clients": {
#      "total": 0,
#      "wifi": 0,
#      "wifi24": 0,
#      "wifi5": 0
#    },
node_json_clients(){
    local i=0
    local total=0
    local wifi24=0
    local wifi5=0
    dev_st=$(devstatus br-freifunk)
    while [ true ]; do
        dev=$(echo $dev_st | jsonfilter -e "@['bridge-members'][$i]")
        if [ -z "$dev" ]; then
            break;
        fi
        stations=$(iw dev $dev station dump | grep "Station" | wc -l)
        if [ "$stations" -gt 0 ]; then
            total=$(( $total + $stations))
            if [ -z "$(iw dev wlan0 info | grep '24.. MHz')" ]; then
                wifi5=$(( $wifi5 + stations ))
            else
               wifi24=$(( $wifi24 + stations ))
            fi
        fi
        i=$(( $i + 1 ))
    done
    echo "\"clients\": { \"total\": $total, \"wifi\": $total, \"wifi24\": $wifi24, \"wifi5\": $wifi5 }"
}

node_json_wifi_neigh() {
    echo "\"wifi\": {"
    # Assuming, that all mesh wifi interfaces are present in bat0
    leading_comma=0
    for interface in $(batctl if | cut -f 1 -d ':'); do
	result=$(iw dev $interface station dump)
	if [ "$leading_comma" -gt 0 ] && ! [ -z "$result" ]; then
            echo ", ";
        fi
        awk -e '{
            if(cnt > 0) {
                print(", ");
            }

            if(match($1,/Station/)) {
                if(scnt > 0){
			print("\n\t\t}, ");
		}
		print("\t\"" $2 "\": {");
                cnt=0;
		scnt=1;
	    } else {
		cnt=1;
		split($0,vals,":");
		gsub(/\W/,"",vals[1]);
		sub(/^\W+/,"",vals[2]);
                printf("\t\t\"%s\": \"%s\"",vals[1],vals[2]);
            }
        }' <<-EOL
$result
EOL

        echo -e "\t} }"
        if [ ! -z "$result" ]; then
            leading_comma=1
        fi
    done
}
#Survey data from wlan0
#        frequency:                      2412 MHz [in use]
#        noise:                          -95 dBm
#        channel active time:            4598809 ms
#        channel busy time:              905739 ms
#        channel receive time:           780478 ms
#        channel transmit time:          76415 ms
#Survey data from wlan0
#        frequency:                      2417 MHz

node_json_survey(){
  echo "\"survey\": {"
    for interf in $(iw dev | grep Interface | grep -v "-" | sed -e s/Interface//); do
      if ! [ -z "$prev_if" ]; then      
                echo ", "
      fi          
      prev_if=$interf  
      echo "\"$interf\": {"
      iw dev $interf survey dump | awk -e '{
          echo -e "\t\t \"$interf\": {"
	  in_use = "false";
          if(match($0,/frequency/)) {
	    if(freq_printed > 0 ) {
              print("},")
            }
            if(match($0,/in use/)){
              in_use="true";
            }
            freq_printed = 1;
            comma_needed = 0;
            printf("\t\t\"%s\": { \n \t\t\t\"in_use\": %s",$2,in_use);
          } 
	   else if(match($0,/:/)) {
	     split($0,vals,":");
	     sub(/channel/,"",vals[1]);
	     gsub(/\t/,"",vals[2]);
             gsub(/\W/,"",vals[1]);
	     printf(", \n\t\t\t\"%s\":\"%s\"",vals[1],vals[2]);
           }
      }'
      echo "} }"
    done
  echo "}"
}

node_json_freifunk_ifstat(){
	devstatus br-freifunk | jsonfilter -e '@.statistics'
}
