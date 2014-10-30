# leds

k_leds_init() {
	[ -n "$K_LEDS_SERIAL_PORT" ] || \
		return 1
	k_log 3 "initializing leds serial port"
	[ -c "$K_LEDS_SERIAL_PORT" ] || { \
		k_log 3 "WARNING: lels serial port not found or not usable"
		return 1
	}
	stty -F $K_LEDS_SERIAL_PORT $K_LEDS_SERIAL_BAUD_RATE cs8 -cstopb -parenb || {\
		k_log 1 "ERROR: error initializing leds serial port"
		return 1
	}
	return 0
}

k_leds_update() {
	local command
	command="$1"
	echo "$command" > $K_LEDS_SERIAL_PORT
}

k_leds_blink() {
	k_log 3 "leds: BLINK"
	k_leds_update 'B'
}

k_leds_on() {
	k_log 3 "leds: ON"
	k_leds_update 'I'
}

k_leds_off() {
	k_log 3 "leds: OFF"
	k_leds_update 'O'
}

k_leds_pulse() {
	k_log 3 "leds: PULSE"
	k_leds_update 'P'
}

k_leds_startup() {
	k_leds_init || \
		return
	k_leds_pulse
	k_hook_register_handler on_media_plugged k_leds_off
	k_hook_register_handler on_media_removed k_leds_pulse
	k_hook_register_handler on_copy_started k_leds_blink
	k_hook_register_handler on_copy_ended k_leds_on
	k_hook_register_handler on_app_ended k_leds_off
}

k_hook_register_handler on_app_started k_leds_startup
