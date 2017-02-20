#!/bin/sh

#Software-Pakete installieren
/lib/freifunk/install_software.sh

if [ $? -ne 0 ]; then
  echo "Fehler beim Installieren der Software - Abbruch"
  exit 2;
fi

# Konfiguration übernehmen
/lib/freifunk/import_configuration.sh

# IP-Adresse setzen
/lib/freifunk/set_ip.sh

# Hinweis auf reboot anzeigen
echo "Konfiguration abgeschlossen --- Node sollte jetzt neu gestartet werden"
