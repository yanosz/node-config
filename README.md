HowTo
==========

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

Die Details
-----------------------
Shell-Scripts installieren die Konfiguration auf dem Node. Es gibt
* [freifunk/install_software.sh](freifunk/install_software.sh) - Installiert benötigte Pakete
* [freifunk/import_configuration.sh](freifunk/import_configuration.sh) - Importiert die Konfiguration
* [freifunk/set_ip.sh](freifunk/set_ip.sh) - Setzt IP-Adressen und Subnets des Nodes in der kompletten Konfiguration
* [freifunk/install.sh](freifunk/install.sh) - Ruft die anderen Scripts in der richtigen Reihenfolge auf


Wenig Speicherplatz?
----------------------
Wenn Dein Node lediglich 4 MB Flash hat (z.B. TP-Link WR841n), dann musst Du ein OpenWRT-Image erstellen, in dem keine WebGUI enthalten ist - zum Beispiel:
```bash
wget http://openwrt.kbu.freifunk.net/chaos_calmer/15.05/ar71xx/generic/OpenWrt-ImageBuilder-15.05-ar71xx-generic.Linux-x86_64.tar.bz2
tar xjf OpenWrt-ImageBuilder-15.05-ar71xx-generic.Linux-x86_64.tar.bz2
cd OpenWrt-ImageBuilder-15.05-ar71xx-generic.Linux-x86_64
make image PROFILE="TLWR841" PACKAGES="ip openvpn-polarssl babeld fastd ebtables kmod-ebtables-ipv4 owipcalc batctl haveged"
```
