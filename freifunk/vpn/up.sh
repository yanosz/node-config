#!/bin/sh

# Fuege eine Default-Route mit Protokoll 43 der Freifunk-Tabelle (66) hinzu
ip route add default dev $DEV table 66 proto static 