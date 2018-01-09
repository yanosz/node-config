#!/bin/sh
bat_neigh() {
        echo '"batadv": {'
        batctl o | awk '{
        # [B.A.T.M.A.N. adv 2016.5, MainIF/MAC: wlan0/10:fe:ed:ba:d4:b4 (bat0/0e:3f:08:fd:0c:20 BATMAN_IV)]
        if(match($6,/bat0/)){
                interface=$6;
                sub(/\(bat0\//,"",interface);
                printf("\"%s\": {",interface);
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
                printf("\"%s\" : { \"tq\":%f, \"lastseen\":%s}\n",originator,tq,last_seen);
        }
    }
'
    echo "} }"
}

wifi_neigh() {
}
