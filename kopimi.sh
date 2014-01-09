#!/bin/sh

set +e

K_ME=${0##*/}
K_MY_DIR=${0%/*}
K_MY_PID=$$
K_VERSION="0.1"

k_usage() {
	cat << _END_OF_USAGE_

Usage: $K_ME OPTIONS

KopimiBox master daemon

Options:
	-C,--cfg-file FILE    use the specified configuration file
	-l,--log-file FILE    log activity to the specified file
	-L,--lib-dir DIR      use the specified lib directory
	                      (for helper functions & scripts)
	-p,--pid-file FILE    log pid to the specified file
	-R,--run-dir DIR      use the specified run directory
	                      (for temporary files storage)

	-v,--verbose          be verbose (use multiple time to increase
	                      verbosity level)

	-V,--version          display program version and exit
	-h,--help             display program usage and exit

_END_OF_USAGE_
}

k_version() {
	cat << _END_OF_VERSION_
$K_ME v$K_VERSION, Copyright (C) 2014 BlackBoxe <contact@blackboxe.org>

_END_OF_VERSION_
}

K_IS_ALIVE=0
K_TIME_START=0
K_OPT_VERBOSE=0

k_error() {
	echo "$K_ME: $@"
	exit 1
}

k_get_options() {
	while [ -n "$1" ]; do
		case $1 in
			-C|--config-file)
				shift
				K_OPT_CONFIG_FILE=$1
				;;
			-l|--log-file)
				shift
				K_OPT_LOG_FILE=$1
				;;
			-L|--lib-dir)
				shift
				K_OPT_LIB_DIR=$1
				;;
			-p|--pid-file)
				shift
				K_OPT_PID_FILE=$1
				;;
			-R|--run-dir)
				shift
				K_OPT_RUN_DIR=$1
				;;
			-v|--verbose)
				K_OPT_VERBOSE=$(($K_OPT_VERBOSE + 1))
				;;
			-vv)
				K_OPT_VERBOSE=$(($K_OPT_VERBOSE + 2))
				;;
			-vvv)
				K_OPT_VERBOSE=$(($K_OPT_VERBOSE + 3))
				;;
			-h|--help)
				k_usage
				exit 0
				;;
			-V|--version)
				k_version
				exit 0
				;;
			*)
				k_error "unknown option '$1'"
				;;
		esac
		shift
	done
}

k_now() {
	date +%s
}

k_log() {
	local level
	local time_now
	local time_str
	local t
	local h
	local m
	local s

	level=$1
	shift

	[ $level -le $K_OPT_VERBOSE ] || return
	time_now=$(k_now)
	t=$(($time_now - $K_TIME_START))
	h=$(($t / 3600))
	t=$(($t % 3600))
	m=$(($t / 60))
	s=$(($t % 60))
	time_str=$(printf "%.2d:%.2d:%.2d" $h $m $s)
	echo "$K_ME [$time_str]: $@" >>$K_LOG_FILE
}

k_rel2abs() {
	local p
	local r
	local d
	local f
	local wd
	r=""
	wd=$(pwd)
	for p in $*; do
		d=${p%/*}
		f=${p##*/}
		cd $d >/dev/null 2>&1 \
			|| h_error "can't use directory '$d' ('$p')"
		d=$(pwd)
		cd $wd
		r="${r}${r:+ }${d}/${f}"
	done
	echo "$r"
}

k_abort() {
	k_log 0 "caught ABORT, exiting gracefully"
	K_IS_ALIVE=0
}

k_startup() {
	K_IS_ALIVE=1
	K_TIME_START=$(k_now)

	if [ -n "$K_OPT_CONFIG_FILE" ]; then
		K_CONFIG_FILE=$K_OPT_CONFIG_FILE
	elif [ -f $K_MY_DIR/kopimi.conf ]; then
		K_CONFIG_FILE=$K_MY_DIR/kopimi.conf
	else
		k_error "can't find any config file, use a '--config-file' option"
	fi
	[ -r $K_CONFIG_FILE ] \
		&& . $K_CONFIG_FILE \
		|| K_error "can't read config file '$K_CONFIG_FILE'"

	if [ -n "$K_OPT_LOG_FILE" ]; then
		K_LOG_FILE=$K_OPT_LOG_FILE
	elif [ -z "$K_LOG_FILE" ]; then
		K_LOG_FILE=$K_MY_DIR/kopimi.log
	fi
	touch $K_LOG_FILE >/dev/null 2>&1 \
		|| k_error "can't create log file '$K_LOG_FILE'"
	K_LOG_FILE=$(k_rel2abs $K_LOG_FILE)

	if [ -n "$K_OPT_PID_FILE" ]; then
		K_PID_FILE=$K_OPT_PID_FILE
	elif [ -z "$K_PID_FILE" ]; then
		K_PID_FILE=$K_MY_DIR/kopimi.pid
	fi
	touch $K_PID_FILE >/dev/null 2>&1 \
		|| k_error "can't create pid file '$K_PID_FILE'"
	K_PID_FILE=$(k_rel2abs $K_PID_FILE)

	[ -n "$K_LIB_DIR" ] \
		|| k_error "can't use library directory, 'K_LIB_DIR' not set"
	K_LIB_DIR=$(k_rel2abs $K_LIB_DIR)

	[ -n "$K_RUN_DIR" ] \
		|| k_error "can't use run directory, 'K_RUN_DIR' not set"
	mkdir -p $K_RUN_DIR >/dev/null 2>&1 \
		|| k_error "can't create run directory '$K_RUN_DIR'"
	K_RUN_DIR=$(k_rel2abs $K_RUN_DIR)

#	K_TMP_DIR=$(mktemp -d $K_RUN_DIR/kopimi-XXXXXX) \
#		|| k_error "can't create tmp directory in '$K_RUN_DIR'"
#	cd $K_TMP_DIR >/dev/null 2>&1 \
#		|| k_error "can't use tmp directory '$K_TMP_DIR'"

	k_log 0 "starting"
	k_log 1 "using config file: $K_CONFIG_FILE"
	k_log 1 "using lib directory: $K_LIB_DIR"
	k_log 1 "using run directory: $K_RUN_DIR"
#	k_log 1 "using tmp directory: $K_TMP_DIR"

	for M in $K_LIB_DIR/[0-9][0-9]-*.sh; do
		k_log 1 "loading module: $M"
		. $M
	done

	echo "$K_MY_PID" > $K_PID_FILE

	k_hook_call_handlers on_app_starting
	k_hook_call_handlers on_app_started

	trap k_abort INT TERM

	k_log 0 "started"
}

k_cleanup() {
	k_hook_call_handlers on_app_ending
	k_hook_call_handlers on_app_ended
	k_log 0 "ended"
}

k_loop() {
	while [ $K_IS_ALIVE -gt 0 ]; do
		k_hook_call_handlers on_app_loop
	done
}

k_get_options $@
k_startup
k_loop
k_cleanup