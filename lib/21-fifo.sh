# fifo

k_fifo_startup() {
	k_log 3 "creating fifo '$K_NOTIFY_FIFO'"
	mkfifo $K_NOTIFY_FIFO || \
		k_log 1 "ERROR: creating fifo '$K_NOTIFY_FIFO'"
	k_log 3 "fifo '$K_NOTIFY_FIFO' created"
}

k_fifo_cleanup() {
	k_log 3 "removing fifo '$K_NOTIFY_FIFO'"
	rm $K_NOTIFY_FIFO || \
		k_log 1 "ERROR: removing fifo '$K_NOTIFY_FIFO'"
	k_log 3 "fifo '$K_NOTIFY_FIFO' removed"
}

k_fifo_wait_for_event() {
	k_log 2 "waiting for event"
	cat $K_NOTIFY_FIFO | while read PROTO ACTION MESSAGE; do
		k_log 3 "received event! Protocol: $PROTO, Action: $ACTION, Message: $MESSAGE"
		if [ $PROTO = "KOPIMI/0.1" ]; then
			if [ $ACTION = "NOTIFY" ]; then
				echo "$MESSAGE" | while read TYPE DEVICE STATE; do
					if [ $TYPE = "USB-STORAGE" ]; then
						if [ $STATE = "ADDED" ]; then
							k_log 2 "USB device '$DEVICE' plugged"
							k_hook_call_handlers on_media_plugged "$DEVICE"
						elif [ $STATE = "REMOVED" ]; then 
							k_log 2 "USB device '$DEVICE' removed"
							k_hook_call_handlers on_media_removed "$DEVICE"
						else
							k_log 1 "ERROR: unknown USB <device state '$STATE'"
						fi
					else
						k_log 1 "ERROR: unknown device type '$TYPE'"
					fi
				done
			elif [ $ACTION = "QUIT" ]; then
				k_quit
			else
				k_log 1 "ERROR: unknown event '$ACTION'"
			fi
		else
			k_log 1 "ERROR: unknown protocol '$PROTO'"
		fi
	done
}

k_hook_register_handler on_app_started k_fifo_startup
k_hook_register_handler on_app_ended k_fifo_cleanup
k_hook_register_handler on_app_loop k_fifo_wait_for_event
