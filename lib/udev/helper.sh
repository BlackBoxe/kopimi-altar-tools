#!/bin/sh

ACTION="$1"
TYPE="$2"
DEVICE="$3"

K_DIR=/opt/kopimi
K_CONF=$K_DIR/kopimi.conf

[ -f "$K_CONF" ] && \
	. $K_CONF

k_notify() {
	local action

	action="$1"

	[ -n "$K_NOTIFY_FIFO" ] || \
		return
	[ -p "$K_NOTIFY_FIFO" ] && \
		echo "KOPIMI/0.1 NOTIFY $TYPE $DEVICE $action" > $K_NOTIFY_FIFO
}

if [ "$ACTION" = "add" ]; then
	k_notify "ADDED"
elif [ "$ACTION" = "remove" ]; then
	k_notify "REMOVED"
fi
