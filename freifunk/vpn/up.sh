#!/bin/sh

# Fuege eine Default-Route mit Protokoll 43 der Freifunk-Tabelle (66) hinzu
# Proto static ist erforderlich, damit es zu hier konfigurierten babel-Export-Rules passt
ip route add default dev $dev table 66 proto static 