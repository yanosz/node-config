Worum geht's?
--------------------
Dieses Projekt enthält einige Konfigurationsdateien, die beispielhaft für einen Freifunk-Node verwendet werden können.
Du kannst die Konfiguration auf Deinen Node kopieren, anpassen und anwenden.

Voraussetzung ist OpenWRT 15.05.1 (Chaos Calmer) mit ausreichend Speicherplatz. Der Node muss mit dem Internet (WAN-Port) und einem PC / Notebook (LAN-Port) verbunden werden.

Auf dem Node wird die Wifi-Konfiguration geändert - damit ist die Installation über Wifi (wlan) nicht möglich. 

In der Anleitung gehe ich davon aus, dass Du mit der Konsole aus Linux (Mac OS, Unix, usw.) vertraut bist, git installiert ist und Du Dich per `ssh` mit dem OpenWRT-Router verbinden kannst. Evtl. musst Du noch Software installieren - auf Windows z.B. cygwin mit bash, git und ssh.

Schnellstart-Anleitung
------------------------
#### Los geht's

Führe folgende Befehle auf Deinem PC oder Laptop aus:

1. Repository klonen `git clone https://github.com/yanosz/node-config.git`
2. Datei auf den Node kopieren: `cd node-config; scp -r freifunk root@192.168.1.1:/lib`
3. Node installieren: `ssh root@192.168.1.1 /lib/freifunk/install.sh`

#### Hinweis: 
* Je nach Community sollten die IP-Adressen in eine Wiki eingetragen werden - für Freifunk KBU:  https://kbu.freifunk.net/wiki/index.php?title=IP_Subnetze#Dezentrale_Nodes
* `192.168.1.1` steht für die LAN IP-Adresse des Routers. Es muss angepasst werden, wenn die LAN IP-Adresse des Routers geändert wurde.


Bekannte Probleme
-----------------------
1. Die DHCPv6-Prefix delegation im ad-hoc Netz ist ungetestet und wahrscheinlich kaputt


Internet freigeben?
------------------------
Du kannst das Internet entweder über einen VPN-Tunnel oder direkt freigeben:

Für einen VPN-Tunnel (z.B. via mullvad) musst Du die entsprechende Anbieter-Konfiguration in `/lib/freifunk/vpn` auf dem Node hinterlegen und in `/etc/config/openvpn` referenzieren.

Wenn Du  Dein eigenes Internet ohne VPN freigeben willst, dann musst Du das entsprechende Forwarding in `/etc/config/firewall` aktivieren und in `/etc/config/network` IPv6-Range Zuweisungen aus `wan6` auf dem Freifunk-Interface erlauben. 
*Hinweis: Du solltest Dein Internet nur dann freigeben, wenn Du Erfahrung im Abuse-Handling hast.* ToDo: IPv4.

Wenig Speicherplatz?
----------------------
Wenn Dein Node lediglich 4 MB Flash hat (z.B. TP-Link WR841n), dann musst Du ein OpenWRT-Image erstellen, in dem keine WebGUI enthalten ist - zum Beispiel:
```bash
wget https://downloads.openwrt.org/chaos_calmer/15.05.1/ar71xx/generic/OpenWrt-ImageBuilder-15.05.1-ar71xx-generic.Linux-x86_64.tar.bz2
tar xjf OpenWrt-ImageBuilder-15.05.1-ar71xx-generic.Linux-x86_64.tar.bz2
cd OpenWrt-ImageBuilder-15.05.1-ar71xx-generic.Linux-x86_64
echo "src/gz yanosz_chaos_calmer_base https://openwrt.yanosz.net/ar71xx/packages/base" >> repositories.conf
make image PROFILE="TLWR841" PACKAGES="ip openvpn-polarssl babeld fastd ebtables kmod-ebtables-ipv4 owipcalc batctl haveged"
```

Um den PPTP-VPN-Client nutzen zu können, musst Du auf openssl verzichten. Ersetze dazu den letzten Befehl:
```bash
make image PROFILE="TLWR841" PACKAGES="ip babeld fastd ebtables kmod-ebtables-ipv4 owipcalc batctl haveged kmod-nf-nathelper-extra kmod-pptp ppp-mod-pptp"
```


Lokaler Supernode?
---------------------
Wenn Du den Node als Supernode für ein Gluon-basiertes Netz nutzen willst, musst Du zunächst fastd dafür aktivieren und die Services neu starten.
Verbinde Dich hierzu per SSH zu Deinem Node und führe die folgenden Befehle aus:

```bash
uci set fastd.kbu_supernode.enabled=1
uci set network.supernode.enabled=1
uci commit
/etc/init.d/fastd restart
/etc/init.d/network restart
/etc/init.d/fastd show_key kbu_supernode
```
Als fastd-Peer in gluon muss die LAN-Adresse Deines Nodes (z.B. `192.168.1.1`) und der fastd Public-Key eintragen werden. Überprüfe, dass der fastd-Peer der einzige konfigurierte Peer ist, damit Du nicht beide Kollisionsdomänen verbindest.

Der letzte Befehl zeigt den fastd Public-Key. Nun kannst Du die WAN-Ports der Gluon-Router (blauer Port) mit den LAN-Ports des Routers (gelbe Ports) verbinden. 

In den [Feeds](https://openwrt.yanosz.net/openwrt-15.05.1/) sind Gluon-Pakete wie bspw. `kmod-batman-adv-legacy` enthalten, die bei Bedarf installiert werden können.

Die Details
-----------------------
#### Shell-Scripts
Shell-Scripts installieren die Konfiguration auf dem Node. Es gibt:
* [freifunk/install_software.sh](freifunk/install_software.sh) - Installiert benötigte Pakete
* [freifunk/import_configuration.sh](freifunk/import_configuration.sh) - Importiert die Konfiguration
* [freifunk/set_ip.sh](freifunk/set_ip.sh) - Setzt IP-Adressen und Subnets des Nodes in der kompletten Konfiguration
* [freifunk/install.sh](freifunk/install.sh) - Ruft die anderen Scripts in der richtigen Reihenfolge auf
* [freifunk/import_feeds.sh](freifunk/import_feeds.sh) - Importiert feeds von https://openwrt.yanosz.net für batman-adv, gluon-Pakete. [signing key](/freifunk/keys) - Siehe auch: https://dev.openwrt.org/ticket/22930 


#### Konfiguration
Die Konfiguration sind .uci-Dateien die importiert werden - ausgenommen ebtables und wireless: Die UCI-Einstellungen werden dynamisch per Shellscript generiert. Ich geb' hier nur eine grobe Übersicht über die enthaltene Konfiguration. **Alle Dateien sind ausführlich kommentiert. Details findest in den Files selbst**. 

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

Eine weitere fastd-Instanz zum Betrieb eines lokalen Supernodes in Gluon-Netzen ist vorhanden, aber deaktivert.

##### Firewall - [freifunk/initial_configuration/firewall.uci](freifunk/initial_configuration/firewall.uci)
Die Firewall definiert Zonen für Freifunk und VPN-Tunnel zum Internet. Verkehr zwischen Freifunk und WAN / LAN wird per default unterbunden.
**Der Node ist per SSH aus dem Freifunk-Netz erreichbar.** 


##### Netzwerk - [freifunk/initial_configuration/network.uci](freifunk/initial_configuration/network.uci)
In der Netzwerk konfiguration sind verschiedene Interfaces für Wifi, fastd, VPN definiert um sie in der Firewall zu registieren.
Darüber hinaus weißt sie dem Node-Interface die konfigurierten IP-Adressen zu und definiert policy-Routing.

Hier gibt es auch eine Konfiguration für PPTP - falls Du ein entsprechendes VPN verwenden willst.

##### OpenVPN - [freifunk/initial_configuration/openvpn.uci](freifunk/initial_configuration/openvpn.uci)
In der UCI-Datei sind Beispiel-Konfigurationen verschieder VPN-Anbieter realisiert. Die Anbieter-Konfiguration selbst findet sich in [freifunk/vpn](freifunk/vpn). Dazu musst Du Zertifikat und Key von Deinem VPN-Anbieter im Dateisystem ablegen und den entsprechenden Eintrag in `/etc/config/openvpn` aktvieren. 

- Mullvad 
    - Zertifikat: `/lib/freifunk/vpn/mullvad/mullvad.crt`
    - Key: `/lib/freifunk/vpn/mullvad/mullvad.key`
- Freifunk Berlin 
    -  Zertifikat: `/lib/freifunk/vpn/freifunk_berlin/berlin.crt`
    -  Key: `/lib/freifunk/vpn/freifunk_berlin/berlin.key`
    -  Infos:  https://wiki.freifunk.net/Vpn03
- Freifunk KBU: 
    - Zertfikat `/lib/freifunk/vpn/freifunk_kbu/<Deine E-Mail-Adresse>.crt` 
    - Key: `/lib/freifunk/vpn/freifunk_kbu/<Deine E-Mail-Adresse>.`
    - Infos: https://kbu.freifunk.net/wiki/vpn-exit
- yanosz (Für Tests): 
    - Zertfikat `/lib/freifunk/vpn/yanosz/<Deine E-Mail-Adresse>.crt` 
    - Key: `/lib/freifunk/vpn/yanosz/<Deine E-Mail-Adresse>.key`
    - Infos: freifunk@yanosz.net

##### Wifi - [freifunk/initial_configuration/wireless.sh](freifunk/initial_configuration/wireless.sh)
Definiert 2 Wifi-Netze (ad-hoc + AP).

Es wird nur das 1. Wifi-Interface (radio0) konfiguriert - idR 2.4 Ghz.

**Achtung:** Bei Anwendung wird ein vorhandenes OpenWRT Wifi gelöscht, da sonst ein unverschlüsselter Accesspoint für das LAN-Netz erstellt werden könnte.


