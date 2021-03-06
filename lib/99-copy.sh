# copy

K_COPY_COUNT=0

k_copy_count_load() {
	[ -n "$K_COPY_COUNT_FILE" ] || \
		return
	[ -r "$K_COPY_COUNT_FILE" ] && \
	K_COPY_COUNT=$(cat $K_COPY_COUNT_FILE)
}

k_copy_count_save() {
	[ -n "$K_COPY_COUNT_FILE" ] || \
		return
	[ -w "$K_COPY_COUNT_FILE" ] && \
		echo "$K_COPY_COUNT" >$K_COPY_COUNT_FILE
}

k_get_mp() {
	local device
	local mp

	device="$1"

	k_log 3 "waiting 10 seconds for device '$device' to settle..."
	for n in 0 1 2 3 4 5 6 7 8 9; do
		mp=$(cat /proc/mounts | grep "^$device" | cut -d ' ' -f 2)
		if [ -n "$mp" ]; then
			k_log 3 "device '$d' mounted on '$mp'"
			echo "$mp"
			return
		fi
		sleep 1
	done
	k_log 1 "ERROR: device '$device' will NOT mount!"
}

k_copy_all() {
	local mode
	local time_limit
	local source
	local target
	local time
	local time_start
	local time_elapsed

	mode="$1"
	source="$2"
	target="$3"
	time_limit=$4

	time_start=$(k_now)
	find "$source" -type f 2>/dev/null | grep -v '/\.' | grep -v '/Kopimi/' > $K_COPY_TEMP_FILE
	count=$(cat $K_COPY_TEMP_FILE | wc -l)
	k_log 2 "copying, mode: $mode, source: '$source', found $count files"
	index=1
	while [ $index -le $count ]; do
		source=$(cat $K_COPY_TEMP_FILE | tail -n -$index | head -n 1)
		if [ -e "$source" ]; then
			k_log 2 "copying, mode: $mode, source: '$source', target: '$target'"
			k_hook_call_handlers on_copy "$mode" "$source"
			rsync -aq "$source" "$target/" >/dev/null 2>&1
		fi
		time=$(k_now)
		time_elapsed=$(($time - $time_start))
		[ $time_elapsed -ge $time_limit ] && break
		index=$(($index + 1))
	done
}

k_copy_random() {
	local mode
	local time_limit
	local source
	local target
	local time
	local time_start
	local time_elapsed
	local rand
	local index
	local count

	mode="$1"
	source="$2"
	target="$3"
	time_limit=$4

	time_start=$(k_now)
	find "$source" -type f 2>/dev/null | grep -v '/\.' | grep -v '/Kopimi/' > $K_COPY_TEMP_FILE
	count=$(cat $K_COPY_TEMP_FILE | wc -l)
	k_log 2 "copying, mode: $mode, source: '$source', found $count files"
	if [ $count -gt 0 ]; then
		while [ 1 ]; do
			if [ -n "$K_RANDOM" ]; then
				source=$(cat $K_COPY_TEMP_FILE | $K_RANDOM $count)
			else
				index=$((($RANDOM % $count) + 1))
				source=$(cat $K_COPY_TEMP_FILE | tail -n -$index | head -n 1)
			fi
			if [ -e "$source" ]; then
				k_log 2 "copying, mode: $mode, source: '$source', target: '$target'"
				k_hook_call_handlers on_copy "$mode" "$source"
				rsync -aq "$source" "$target/" >/dev/null 2>&1
			fi
			time=$(k_now)
			time_elapsed=$(($time - $time_start))
			[ $time_elapsed -ge $time_limit ] && break
		done
	fi
}

k_copy() {
	local device
	local mp
	local source
	local target

	device="$1"

	k_log 3 "media '$device' plugged, scanning partitions..."
	for d in $device $device[1-9]; do
		k_log 3 "media '$device', partition '$d' found!"
		mp=$(k_get_mp $d)
		if [ -n "$mp" ]; then
			K_COPY_COUNT=$(($K_COPY_COUNT + 1))
			k_log 2 "media '$device', copy #$K_COPY_COUNT started..."
			k_hook_call_handlers on_copy_started "$K_COPY_COUNT" "$mp"
			k_copy_all "OUTGOING-ALWAYS" "$K_DATA_DIR/outgoing/always" "$mp/Kopimi" $K_COPY_OUTGOING_TIME_LIMIT
			k_copy_random "OUTGOING-RANDOM" "$K_DATA_DIR/outgoing/random" "$mp/Kopimi" $K_COPY_OUTGOING_TIME_LIMIT
			k_copy_random "OUTGOING-SHARED" "$K_DATA_DIR/incoming" "$mp/Kopimi" $K_COPY_OUTGOING_TIME_LIMIT
			k_copy_random "INCOMING" "$mp" "$K_DATA_DIR/incoming" $K_COPY_INCOMING_TIME_LIMIT
			k_log 2 "syncing"
			sync
			umount $mp
			k_log 2 "media '$device', copy #$K_COPY_COUNT done!"
			k_hook_call_handlers on_copy_ended "$K_COPY_COUNT"
			k_copy_count_save
			return
		fi
	done
}

k_copy_startup() {
	[ -r "$K_COPY_COUNT_FILE" ] && \
		k_copy_count_load
	# try to use 'random' command from bsdgames if available
	K_RANDOM="$(which random)"
	k_hook_register_handler on_media_plugged k_copy
}

k_hook_register_handler on_app_started k_copy_startup
