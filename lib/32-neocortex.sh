# neocortex (see ./arduino/neocortex/neocortex.ino)

K_NEOCORTEX_READER_PID=
K_NEOCORTEX_WRITER_PID=

k_neocortex_init() {
	[ -n "$K_NEOCORTEX_SERIAL_PORT" ] || \
		return 1
	k_log 3 "initializing neocortex"
	[ -c "$K_NEOCORTEX_SERIAL_PORT" ] || { \
		k_log 3 "WARNING: neocortex serial port not found or not usable"
		return 1
	}
	stty -F $K_NEOCORTEX_SERIAL_PORT $K_NEOCORTEX_SERIAL_BAUD_RATE cs8 -cstopb -parenb || { \
		k_log 1 "ERROR: error initializing neocortx serial port"
		return 1
	}
	return 0
}


k_neocortex_send() {
	local command
	command="$1"
	echo "$command" > $K_NEOCORTEX_SERIAL_PORT
}

k_neocortex_reader() {
	local state_old
	local state_new
	state_old=""
	while read state_new <> $K_NEOCORTEX_SERIAL_PORT; do
		if [ "$state_new" = "1" -a "$state_old" = "0" ]; then
			echo "KOPIMI/0.1 NOTIFY BUTTON 1 PRESSED" > $K_CTL_FIFO
		fi
		state_old="$state_new"
	done
}

k_neocortex_writer() {
	while [ true ]; do
		k_neocortex_send 'T'
		sleep 1
	done
}

k_neocortex_led_blink() {
	k_log 3 "neocortex: led blink"
	k_neocortex_send 'B'
}

k_neocortex_led_on() {
	k_log 3 "neocortex: led on"
	k_neocortex_send 'I'
}

k_neocortex_led_off() {
	k_log 3 "neocortex: led off"
	k_neocortex_send 'O'
}

k_neocortex_led_pulse() {
	k_log 3 "neocortex: led pulse"
	k_neocortex_send 'P'
}

k_neocortex_startup() {
	k_neocortex_init || \
		return
	k_neocortex_led_pulse
	k_hook_register_handler on_app_ended k_neocortex_cleanup
	k_hook_register_handler on_media_plugged k_neocortex_led_off
	k_hook_register_handler on_media_removed k_neocortex_led_pulse
	k_hook_register_handler on_copy_started k_neocortex_led_blink
	k_hook_register_handler on_copy_ended k_neocortex_led_on
	k_hook_register_handler on_video_capture_started k_neocortex_led_on
	k_hook_register_handler on_video_capture_ended k_neocortex_led_pulse
	k_log 3 "neocortex: starting reader"
	k_neocortex_reader &
	K_NEOCORTEX_READER_PID=$!
	k_log 3 "neocortex: starting writer"
	k_neocortex_writer &
	K_NEOCORTEX_WRITER_PID=$!
}

k_neocortex_cleanup() {
	k_log 3 "neocortex: stopping writer"
	kill -TERM $K_NEOCORTEX_READER_PID >/dev/null 2>&1
	k_log 3 "neocortex: stopping reader"
	kill -TERM $K_NEOCORTEX_WRITER_PID >/dev/null 2>&1
	k_neocortex_led_off
}

k_hook_register_handler on_app_starting k_neocortex_startup
