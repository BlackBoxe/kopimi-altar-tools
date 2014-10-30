# video

K_VIDEO_COUNT=0

K_FSWEBCAM_OPTIONS="-q -d $K_VIDEO_DEVICE -D 5 -S 15 -r 640x480 --jpeg 95 --no-banner"
K_FSWEBCAM_OUTPUT_FNAME_FMT="$K_DATA_DIR/incoming/kopimi-photo-%04d.jpeg"

k_video_init() {
	k_log 3 "initializing video support"
	[ -c "$K_VIDEO_DEVICE" ] || { \
		k_log 3 "WARNING: video support not found"
		return 1
	}
	which fswebcam >/dev/null || {
		k_log 3 "WARNING: video capture program not found"
		return 1
	}
	return 0
}

k_video_count_load() {
	[ -n "$K_VIDEO_COUNT_FILE" ] || \
		return
	[ -r "$K_VIDEO_COUNT_FILE" ] && \
		K_VIDEO_COUNT=$(cat $K_VIDEO_COUNT_FILE)
}

k_video_count_save() {
	[ -n "$K_VIDEO_COUNT_FILE" ] || \
		return
	[ -w "$K_VIDEO_COUNT_FILE" ] && \
		echo "$K_VIDEO_COUNT" >$K_VIDEO_COUNT_FILE
}


k_video_capture() {
	local output_f
	k_log 2 "video: capturing frame"
	K_VIDEO_COUNT=$(($K_VIDEO_COUNT + 1))
	k_hook_call_handlers on_video_capture_started "$K_VIDEO_COUNT"
	output_f=$(printf $K_FSWEBCAM_OUTPUT_FNAME_FMT $K_VIDEO_COUNT)
	k_log 3 "video: running command 'fswebcam $K_FSWEBCAM_OPTIONS $output_f'"
	fswebcam $K_FSWEBCAM_OPTIONS $output_f
	k_log 2 "video: frame saved in '$output_f'"
	k_hook_call_handlers on_video_capture_ended "$K_VIDEO_COUNT"
}

k_video_startup() {
	k_video_init || \
		return
	k_video_count_load
	k_hook_register_handler on_button_pressed k_video_capture
	k_hook_register_handler on_video_capture_ended k_video_count_save
}

k_hook_register_handler on_app_started k_video_startup
