# leds

k_leds_gpiod_update() {
	local command
	command="$1"
	k_log 3 "changing leds GPIO #$K_LEDS_GPIOD_NUM, $command"
	echo "$command $K_LEDS_GPIOD_NUM" > $K_LEDS_GPIOD_FIFO
	sleep 1
}

k_leds_gpiod_init() {
	[ -p "$K_LEDS_GPIOD_FIFO" ] || {
		k_log 3 "WARNING: gpiod support not found"
		return 1
	}
	k_log 3 "initializing leds GPIO support"
	k_leds_gpiod_update 'INIT'
	return 0
}

k_leds_gpiod_blink() {
	k_leds_gpiod_update 'BLINK'
	k_leds_gpiod_update 'BLINK'
}

k_leds_gpiod_on() {
	k_leds_gpiod_update 'ON'
}

k_leds_gpiod_off() {
	k_leds_gpiod_update 'OFF'
}

k_leds_gpiod_pulse() {
	k_leds_gpiod_update 'PULSE'
}

k_leds_gpiod_startup() {
	k_leds_gpiod_init || \
		return
	k_leds_gpiod_pulse
	k_hook_register_handler on_media_plugged k_leds_gpiod_off
	k_hook_register_handler on_media_removed k_leds_gpiod_pulse
	k_hook_register_handler on_copy_started k_leds_gpiod_blink
	k_hook_register_handler on_copy_ended k_leds_gpiod_on
	k_hook_register_handler on_app_ended k_leds_gpiod_off
}

k_hook_register_handler on_app_started k_leds_gpiod_startup
