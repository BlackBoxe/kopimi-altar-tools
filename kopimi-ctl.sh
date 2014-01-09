#!/bin/sh

K_ACTION="$1"

K_DIR="/opt/kopimi"
K_CONF="$K_DIR/kopimi.conf"
[ -f "$K_CONF" ] && . $K_CONF

k_start() {
	($K_DIR/kopimi.sh &)&
}

k_stop() {
	[ -n "$K_NOTIFY_FIFO" ] || \
		return
	[ -p "$K_NOTIFY_FIFO" ] && \
		echo "KOPIMI/0.1 QUIT" > $K_NOTIFY_FIFO
}

case $K_ACTION in
  start)
    k_start
    ;;
  stop)
    k_stop
    ;;
esac
