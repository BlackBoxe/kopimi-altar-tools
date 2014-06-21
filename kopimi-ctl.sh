#!/bin/sh

K_ACTION="$1"

K_DIR="/opt/kopimi"
K_CONF="$K_DIR/kopimi.conf"
[ -f "$K_CONF" ] && . $K_CONF

k_start() {
	($K_DIR/kopimi.sh &)&
}

k_stop() {
	[ -n "$K_CTL_FIFO" ] || \
		return
	[ -p "$K_CTL_FIFO" ] && \
		echo "KOPIMI/0.1 QUIT" > $K_CTL_FIFO
}

case $K_ACTION in
  start)
    k_start
    ;;
  stop)
    k_stop
    ;;
esac
