function ssh_init_files() {
	local _ssh_pid_file="$HOME/.config/ssh-agent.pid"
	local _ssh_sock_file="$HOME/.config/ssh-agent.sock"

	for f in "${_ssh_pid_file}" "${_ssh_sock_file}"; do
		if [[ ! -f "${f}" ]]; then
			touch "${f}"
		fi
	done
}

function ssh_start_agent() {
	local ssh_pid_file="$HOME/.config/ssh-agent.pid"
	SSH_AUTH_SOCK="$HOME/.config/ssh-agent.sock"

	if [ -z "$SSH_AGENT_PID" ]; then
		# no PID exported, try to get it from pidfile
		SSH_AGENT_PID=$(cat "$ssh_pid_file")
	fi

	if ! ps -p ${SSH_AGENT_PID} >/dev/null; then
		# the agent is not running, start it
		rm "$SSH_AUTH_SOCK" &>/dev/null
		>&2 echo "Starting SSH agent, since it's not running; this can take a moment"
		eval "$(ssh-agent -s -a "$SSH_AUTH_SOCK")"
		echo "$SSH_AGENT_PID" >"$ssh_pid_file"
		if [[ -f "$HOME/.ssh/config" ]]; then
			ssh-add -H "$HOME/.ssh/config" 2>/dev/null
		fi

		>&2 echo "Started ssh-agent with '$SSH_AUTH_SOCK'"
	fi
	export SSH_AGENT_PID
	export SSH_AUTH_SOCK
}
