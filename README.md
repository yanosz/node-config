Please see [Readme.en.md] for an English version.

Worum geht's?
--------------------
Dieses Projekt enthält einige Konfigurationsdateien, die beispielhaft für einen Freifunk-Node verwendet werden können.
Du kannst die Konfiguration auf Deinen Node kopieren, anpassen und anwenden.

Voraussetzung ist LEDE 17.01 mit ausreichend Speicherplatz. Der Node muss mit dem Internet (WAN-Port) und einem PC / Notebook (LAN-Port) verbunden werden.
Die alte OpenWRT Konfiguration (Chaos Calmer) findet sich im Branch `openwrt`. Die

In der Anleitung gehe ich davon aus, dass Du mit der Konsole aus Linux (Mac OS, Unix, usw.) vertraut bist, git installiert ist und Du Dich per `ssh` mit dem lede-Router verbinden kannst. Evtl. musst Du noch Software installieren - auf Windows z.B. cygwin mit bash, git und ssh.

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
1. Die Installation des ebtables-Pakets schlägt fehl, da Module bereits geladen werden. Der Fehler kann ignogiert werden.
2. Die DHCPv6-Prefix delegation im ad-hoc Netz ist ungetestet und wahrscheinlich kaputt


Internet freigeben?
------------------------
Du kannst das Internet entweder über einen VPN-Tunnel oder direkt freigeben:

#### OpenVPN-Tunnel

Für einen VPN-Tunnel (z.B. via mullvad) musst Du die entsprechende Anbieter-Konfiguration in `/lib/freifunk/vpn`
auf dem Node hinterlegen und in [`/etc/config/openvpn`](freifunk/initial_configuration/openvpn.uci) aktivieren.

Falls Du einen anderen OpenVPN-Provider nutzen willst, kannst Du Dich an der existierenden Konfiguration orientieren.
Vergiss nicht, die Routes in die Freifunk Routing-Tabelle zu schreiben. Setze hierzu die Optionen: `route-nopull`, `script-security 2` und `up /lib/freifunk/vpn/up.sh` ([Beispiel](freifunk/vpn/yanosz/client.conf)).

#### Eigenes Internet direkt freigeben

Wenn Du  Dein eigenes Internet ohne VPN freigeben willst, geh' wie folgt vor:
```bash
uci set network.internet_share.disabled=0
uci set network.internet_share6.disabled=0
uci firewall.freifunk_internet.dest='wan'
uci commit firewall
uci commet network
/etc/init.d/firewall restart
/etc/init.d/network restart
```

Indem Du `internet_share` und `internet_share6` aktivierst, werden die routes in die Freifunk Routing Tabelle eingetragen.
Mit Umleiten der `dest` auf `wan` erlaubst Du in der Firewall, dass Pakete über Dein Internet ausgeleitet werden.

**Hinweis**: *Du solltest Dein Internet nur dann freigeben, wenn Du Erfahrung im Abuse-Handling hast.*

Wenig Speicherplatz?
----------------------
Wenn Dein Node lediglich 4 MB Flash hat (z.B. TP-Link WR841n), dann musst Du ein LEDE-Image erstellen, in dem keine WebGUI enthalten ist - zum Beispiel:
```bash
wget http://downloads.lede-project.org/releases/17.01.4/targets/ar71xx/generic/lede-imagebuilder-17.01.4-ar71xx-generic.Linux-x86_64.tar.xz
tar xf lede-imagebuilder-17.01.4-ar71xx-generic.Linux-x86_64.tar.xz
cd lede-imagebuilder-17.01.4-ar71xx-generic.Linux-x86_64
make image PROFILE="TLWR841" PACKAGES="ip openvpn-mbedtls  babeld fastd owipcalc batctl haveged kmod-nf-nathelper-extra kmod-pptp ppp-mod-pptp  ebtables kmod-ebtables-ipv4"
```

Um den PPTP-VPN-Client nutzen zu können, musst Du auf openssl verzichten. Ersetze dazu den letzten Befehl:
```bash
make image PROFILE="TLWR841" PACKAGES="ip babeld fastd owipcalc batctl haveged kmod-nf-nathelper-extra kmod-pptp ppp-mod-pptp  ebtables kmod-ebtables-ipv4 kmod-nf-nathelper-extra kmod-pptp ppp-mod-pptp"
```


Lokaler Supernode?
---------------------
Wenn Du den Node als Supernode für ein Gluon-basiertes Netz nutzen willst, musst Du zunächst fastd dafür aktivieren und die Services neu starten.
Verbinde Dich hierzu per SSH zu Deinem Node und führe die folgenden Befehle aus:

```bash
uci set fastd.supernode.enabled=1
uci commit
/etc/init.d/fastd restart
/etc/init.d/fastd show_key supernode
```
Als fastd-Peer in gluon muss die LAN-Adresse Deines Nodes (z.B. `192.168.1.1`) und der fastd Public-Key eintragen werden. Überprüfe, dass der fastd-Peer der einzige konfigurierte Peer ist, damit Du nicht beide Kollisionsdomänen verbindest.

Der letzte Befehl zeigt den fastd Public-Key. Nun kannst Du die WAN-Ports der Gluon-Router (blauer Port) mit den LAN-Ports des Routers (gelbe Ports) verbinden.

LEDE-Pakete? GUI? Firmware ?
-----------------------------

Du kannst auch opkg-Pakete obauen. Werf' einen Blick ins [Makefile](Makefile) `make world` baut alle notwendigen Pakete.

Die GUI ist noch recht roh. Details gibt's hier: https://github.com/yanosz/firmware-wizard-frontend

Für Firmware-Files schau auf https://git.kbu.freifunk.net/yanosz/node-config-feed - denk' daran, die submodules zu aktualisieren.
Die Firmware-Files enthalten auch die GUI.


Die Details
-----------------------
#### Shell-Scripts
Shell-Scripts installieren die Konfiguration auf dem Node. Es gibt:
* [freifunk/install_software.sh](freifunk/install_software.sh) - Installiert benötigte Pakete
* [freifunk/import_configuration.sh](freifunk/import_configuration.sh) - Importiert die Konfiguration
* [freifunk/set_ip.sh](freifunk/set_ip.sh) - Setzt IP-Adressen und Subnets des Nodes in der kompletten Konfiguration
* [freifunk/install.sh](freifunk/install.sh) - Ruft die anderen Scripts in der richtigen Reihenfolge auf

#### Konfiguration
Die Konfiguration sind .uci-Dateien die importiert werden - ausgenommen ebtables und wireless: Die UCI-Einstellungen werden dynamisch per Shellscript generiert. Ich geb' hier nur eine grobe Übersicht über die enthaltene Konfiguration. **Alle Dateien sind ausführlich kommentiert. Details findest in den Files selbst**.

##### Babeld - [freifunk/initial_configuration/babeld.uci](freifunk/initial_configuration/babeld.uci)
babeld wird als Routing-Protokoll genutzt. Es nutzt sowohl das ad-hoc Interface zum meshing und ein fastd-Interface zur Anbindung an weitere nodes und das ICVPN.

##### batman-adv - [freifunk/initial_configuration/batman-adv.uci](freifunk/initial_configuration/batman-adv.uci)
batman-adv wird zum Roaming innerhalb des Meshes verwendet. Jeder Node ist Gateway, d.h. betreibt einen dhcp-Server.

##### dhcp / radvd - [freifunk/initial_configuration/dhcp.uci](freifunk/initial_configuration/dhcp.uci)
Für Clients am Accesspoint wird ein IPv4-DHCP-Server und ein radvd definiert. Es werden private bzw. ULA-Adressen verwendet. Falls Public IPv6-Adressen zur Verfügung stehen werden sie auch verwendet. Die Konfiguration ist ein Shell-Script, da `/etc/firewall.user` nicht per UCI verwaltet wird.

##### Multicast-Filter - [freifunk/initial_configuration/firewall.sh](freifunk/initial_configuration/firewall.sh)
Multicast / Anycast im batman-adv Mesh wird stark eingeschränkt, da das mesh nur zum Roaming verwendet wird.
Ebenso werden hier ip-rules gesetzt.

##### fastd - [freifunk/initial_configuration/fastd.uci](freifunk/initial_configuration/fastd.uci)
Per fastd wird eine Verbindung zu anderen Nodes aufgebaut, zu denen kein Funkkontakt besteht. Testweise ist ein Node mit Zugang zum ICVPN hinterlegt. Zum Routing wird babeld verwendet. Mit [freifunk/initial_configuration/fastd_binding.sh](freifunk/initial_configuration/fastd_binding.sh) werden die bindings für LAN und WAN entsprechend der Interface-Namen gesetzt.

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

Falls ein 2. Wifi-Device vorhanden ist (radio1) wird ist als 5 Ghz Wifi für den Kanal 36 konfiguriert.

Falls eine eindeutige lede default Konfiguration auf einem deaktivierten WLAN erstellt ist, so wird die Konfiguration gelöscht.
