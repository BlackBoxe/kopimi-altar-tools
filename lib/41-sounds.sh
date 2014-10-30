# snd

k_snd_play_file() {
	local file
	local args
	file="$1"
	args=""
	if [ -n "$K_SND_VOLUME" ]; then
		args="$args vol $K_SND_VOLUME"
	fi
	play -q $file $args >/dev/null 2>&1
}

k_snd_play_random() {
	local type
	[ -f $K_SND_TEMP_FILE ] && rm $K_SND_TEMP_FILE 
	for type in "$@"; do
		find "$K_SND_DIR" -type f -name $type-*.wav 2>/dev/null >> $K_SND_TEMP_FILE
	done
	count=$(cat $K_SND_TEMP_FILE | wc -l)
	if [ $count -gt 0 ]; then
		k_log 4 "found '$count' audio files, type '$type'"
		index=$(($RANDOM % $count + 1))
		source=$(cat $K_SND_TEMP_FILE | tail -n -$index | head -n 1)
		k_log 4 "playing '$source'"
		k_snd_play_file $source
	else
		k_log 3 "WARNING: no audio files found"
	fi 
}

k_snd_on_idle() {
	k_snd_play_random "01" "02" "04"
	sleep 1
	k_snd_play_random "03"
}

k_snd_init() {
	[ -n "$K_SND_DEVICE" ] || \
		return 1
	k_log 3 "initializing sound support"
	[ -c "$K_SND_DEVICE" ] || {
		k_log 3 "WARNING: sound support not found"
		return 1
	}
	[ -p "$K_SND_FIFO" ] || \
		mkfifo $K_SND_FIFO || {
			k_log 1 "ERROR: creating fifo '$K_SND_FIFO'"
			return 1
		}

	return 0
}

k_snd_on_copy_started() {
	k_snd_play_random "11"
}

k_snd_on_copy() {
	local f
	local f_ext
	local f_mime
	local f_goodness
	m="$1"
	f="$2"
	f_ext="${f##*.}"
	f_ext="$(echo $f_ext | tr 'A-Z' 'a-z')"
	f_mime="$(file --mime-type $f)"
	f_goodness=50
	case $f_ext in
	  blend|c|cpp|sc|scad|stl|svg)
	    f_goodness=99
	    ;;
	  jpg|jpeg|pd|png)
	    f_goodness=80
	    ;;
	  ino|lua|odf|odp|ods|odt|ogg|pde|py|pyc|rb)
	    f_goodness=75
	    ;;
	  avi|mp3|mp4|mkv|pdf|txt|xthml|wav)
	    f_goodness=60
	    ;;
	  3ds)
	    f_goodness=49
	    ;;
	  max)
	    f_goodness=30
	    ;;
	  csv)
	    f_goodness=1
	    ;;
	  com|dll|doc|docx|dxf|exe|gif|ini|ppt|pptx|xls|xlsx)
	    f_goodness=0
	    ;;
	esac
	k_log 4 "analyzed file '$f', ext: $f_ext, mime: $f_mime, score: $f_goodness"
	if [ $f_goodness -gt 70 ]; then
		k_snd_play_random "12"
	elif  [ $f_goodness -lt 30 ]; then
		k_snd_play_random "13"
	fi
}

k_snd_on_copy_ended() {
	k_snd_play_random "14"
	sleep 1
	k_snd_play_random "15"
}

k_snd_startup() {
	k_snd_init || \
		return
	k_hook_register_handler on_idle k_snd_on_idle
	k_hook_register_handler on_copy_started k_snd_on_copy_started
	k_hook_register_handler on_copy k_snd_on_copy
	k_hook_register_handler on_copy_ended k_snd_on_copy_ended
}

k_hook_register_handler on_app_started k_snd_startup
