#!/bin/sh

#Software-Pakete installieren
/lib/freifunk/install_software.sh

# Konfiguration übernehmen
/lib/freifunk/import_confiugration.sh

# IP-Adresse setzen
/lib/freifunk/set_ip.sh

# Hinweis auf reboot anzeigen
echo "Konfiguration abgeschlossen --- Node sollte jetzt neu gestartet werden"