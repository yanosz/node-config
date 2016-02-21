Worum geht's?
--------------------
Dieses Projekt enthält einige Konfigurationsdateien, die beispielhaft für einen Freifunk-Node verwendet werden können.
Du kannst die Konfiguration auf Deinen Node kopieren, anpassen und anwenden.

Voraussetzung ist OpenWRT 15.05 (Chaos Calmer) mit ausreichend Speicherplatz. 

Schnellstart-Anleitung
------------------------
Hinweis: Die IP-Adressen müssen in die Wiki eintragen werden (vgl. :

1. Repository auf dem PC / Laptop klonen `git clone https://github.com/yanosz/node-config.git`
2. Datei auf den Node kopieren: `cd node-config; scp -r freifunk root@<IP des Nodes>:/lib`
3. Node installieren: `ssh root@<IP des Nodes> /lib/freifunk/install.sh`

Internet freigeben?
------------------------
Du kannst das Internet entweder über einen VPN-Tunnel oder direkt freigeben:

Für einen VPN-Tunnel (z.B. via mullvad) musst Du die entsprechende Anbieter-Konfiguration in `/lib/freifunk/vpn` auf dem Node hinterlegen und in `/etc/config/openvpn` referenzieren.

Wenn Du  Dein eigenes Internet ohne VPN freigeben willst, dann musst Du das entsprechende Forwarding in `/etc/config/firewall` aktivieren und in `/etc/config/network` IPv6-Range Zuweisungen aus `wan6` auf dem Freifunk-Interface erlauben. 
*Hinweis: Du solltest Dein Internet nur dann freigeben, wenn Du Erfahrung im Abuse-Handling hast.*

Wenig Speicherplatz?
----------------------
Wenn Dein Node lediglich 4 MB Flash hat (z.B. TP-Link WR841n), dann musst Du ein OpenWRT-Image erstellen, in dem keine WebGUI enthalten ist - zum Beispiel:
```bash
wget http://openwrt.kbu.freifunk.net/chaos_calmer/15.05/ar71xx/generic/OpenWrt-ImageBuilder-15.05-ar71xx-generic.Linux-x86_64.tar.bz2
tar xjf OpenWrt-ImageBuilder-15.05-ar71xx-generic.Linux-x86_64.tar.bz2
cd OpenWrt-ImageBuilder-15.05-ar71xx-generic.Linux-x86_64
make image PROFILE="TLWR841" PACKAGES="ip openvpn-polarssl babeld fastd ebtables kmod-ebtables-ipv4 owipcalc batctl haveged"
```

Die Details
-----------------------
#### Shell-Scripts
Shell-Scripts installieren die Konfiguration auf dem Node. Es gibt:
* [freifunk/install_software.sh](freifunk/install_software.sh) - Installiert benötigte Pakete
* [freifunk/import_configuration.sh](freifunk/import_configuration.sh) - Importiert die Konfiguration
* [freifunk/set_ip.sh](freifunk/set_ip.sh) - Setzt IP-Adressen und Subnets des Nodes in der kompletten Konfiguration
* [freifunk/install.sh](freifunk/install.sh) - Ruft die anderen Scripts in der richtigen Reihenfolge auf

#### Konfiguration
Die Konfiguration sind .uci-Settings die importiert wird. Ausnahmen: ebtables und wireless. Hier können keine .uci-Settings merged werden. Ich geb' hier nur eine grobe Übersicht über die enthaltene Konfiguration. **Alle Dateien sind ausführlich kommentiert. Details findest in den Files selbst**. 

##### Babeld - [freifunk/initial_configuration/babeld.uci](freifunk/initial_configuration/babeld.uci)
babeld wird als Routing-Protokoll genutzt. Es nutzt sowohl das ad-hoc Interface zum meshing und ein fastd-Interface zur Anbindung an weitere Supernodes und das ICVPN.

##### batman-adv - [freifunk/initial_configuration/batman-adv.uci](freifunk/initial_configuration/batman-adv.uci)
batman-adv wird zum Roaming innerhalb des Meshes verwendet. Jeder Node ist Gateway, d.h. betreibt einen dhcp-Server.

##### dhcp / radvd - [freifunk/initial_configuration/dhcp.uci](freifunk/initial_configuration/dhcp.uci)
Für Clients am Accesspoint wird ein IPv4-DHCP-Server und ein radvd definiert. Es werden private bzw. ULA-Adressen verwendet. Falls Public IPv6-Adressen zur Verfügung stehen werden sie auch verwendet. Die Konfiguration ist ein Shell-Script, da `/etc/firewall.user` nicht per UCI verwaltet wird.

##### Multicast-Filter - [freifunk/initial_configuration/ebtables.sh](freifunk/initial_configuration/ebtables.sh)
Multicast / Anycast im batman-adv Mesh wird stark eingeschränkt, da das mesh nur zum Roaming verwendet wird.

##### fastd - [freifunk/initial_configuration/fastd.uci](freifunk/initial_configuration/fastd.uci)
Per fastd wird eine Verbindung zu anderen Nodes aufgebaut, zu denen kein Funkkontakt besteht. Testweise ist ein Node mit Zugang zum ICVPN hinterlegt. Zum Routing wird babeld verwendet.

##### Firewall - [freifunk/initial_configuration/firewall.uci](freifunk/initial_configuration/firewall.uci)
Die Firewall definiert Zonen für Freifunk und VPN-Tunnel zum Internet. Verkehr zwischen Freifunk und WAN / LAN wird per default unterbunden.

##### Netzwerk - [freifunk/initial_configuration/network.uci](freifunk/initial_configuration/network.uci)
In der Netzwerk konfiguration sind verschiedene Interfaces für Wifi, fastd, VPN definiert um sie in der Firewall zu registieren.
Darüber hinaus weißt sie dem Node-Interface die konfigurierten IP-Adressen zu und definiert policy-Routing.

##### OpenVPN - [freifunk/initial_configuration/openvpn.uci](freifunk/initial_configuration/openvpn.uci)
In der UCI-Datei sind Beispiel-Konfigurationen verschieder VPN-Anbieter realisiert. Die Anbieter-Konfiguration selbst findet sich in [freifunk/vpn](freifunk/vpn).

##### Wifi - [freifunk/initial_configuration/wireless.sh](freifunk/initial_configuration/wireless.sh)
Definiert 2 Wifi-Netze (ad-hoc + AP).

**Achtung:** Bei Anwendung wird ein vorhandenes OpenWRT Wifi gelöscht, da sonst ein unverschlüsselter Accesspoint für das LAN-Netz erstellt werden könnte.


