#!/bin/sh

mkdir -p /run/dump1090-fa
dump1090-fa --write-json /run/dump1090-fa --quiet "$@" &
lighttpd -f /etc/lighttpd/lighttpd.conf -D
