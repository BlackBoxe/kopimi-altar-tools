# hooks

k_hook_register_handler() {
	local hook
	local handler
	local handlers
	local hook_var
	hook=$1
	handler=$2
	hook_var="K_HOOK_$hook"
	eval "handlers=\"\${$hook_var}\""
	eval "$hook_var=\"$handlers $handler \""
}

k_hook_unregister_handler() {
	local hook
	local handler
	local handlers
	local hook_var
	hook=$1
	handler=$2
	hook_var="K_HOOK_$hook"
	eval "handlers=\"\${$hook_var}\""
	eval "$hook_var=\"\$(echo $handlers | sed -e 's/ $handler / /')\""
}

k_hook_call_handlers() {
	local hook
	local args
	local handler
	local handlers
	local hook_var
	hook=$1
	shift
	args="$*"
	hook_var="K_HOOK_$hook"
	eval "handlers=\"\${$hook_var}\""
	k_log 4 "calling '$hook' handlers"
	for handler in $handlers; do
		$handler $args # || return
	done
}
