function ssh_init_files() {
	local _ssh_pid_file="$HOME/.config/ssh-agent.pid"
	local _ssh_sock_file="$HOME/.config/ssh-agent.sock"

	for f in "${_ssh_pid_file}" "${_ssh_sock_file}"; do
		if [[ ! -f "${f}" ]]; then
			touch "${f}"
		fi
	done
}

function _ssh_start_agent() {
	local ssh_pid_file=$1
	local ssh_auth_sock=$2
	rm "$ssh_auth_sock" &>/dev/null
	eval "$(ssh-agent -s -a "$ssh_auth_sock")"
	echo "$SSH_AGENT_PID" >"$ssh_pid_file"
	if [[ -f "$HOME/.ssh/config" ]]; then
		ssh-add -H "$HOME/.ssh/config" 2>/dev/null
	fi
}

function ssh_start_agent() {
	local ssh_pid_file="$HOME/.config/ssh-agent.pid"
	SSH_AUTH_SOCK="$HOME/.config/ssh-agent.sock"

	# Get agent PIDs for env and file
	# if agent from file is running
	  # Check if from env is running - kill if yes
	  # Set env var from file
	# If 

	ssh_agent_pid_from_file=$(cat "$ssh_pid_file")
	if [ -z "$SSH_AGENT_PID" ]; then
		# no PID exported, try to get it from pidfile
		SSH_AGENT_PID=${ssh_agent_pid_from_file}
	fi

	if [[ "${SSH_AGENT_PID}" -eq "${ssh_agent_pid_from_file}" ]]; then
		if ! ps -p ${SSH_AGENT_PID} >/dev/null; then
			# the agent is not running, start it
			>&2 echo "Starting SSH agent, since it's not running; this can take a moment"
			_ssh_start_agent "${ssh_pid_file}" "${SSH_AUTH_SOCK}"
			>&2 echo "Started ssh-agent with '$SSH_AUTH_SOCK'"
		fi
	else
		>&2 echo "Environment SSH pid ${SSH_AGENT_PID} doesn't equal to file PID ${ssh_agent_pid_from_file}"

		if ps -p ${ssh_agent_pid_from_file} >/dev/null; then
			>&2 echo "SSH agent from file ${ssh_agent_pid_from_file} is running"
			>&2 echo "Setting env var to PID ${ssh_agent_pid_from_file}"
			export SSH_AGENT_PID="${ssh_agent_pid_from_file}"
		else
			>&2 echo "SSH agent from file ${ssh_agent_pid_from_file} is not running"
			if ! ps -p ${SSH_AGENT_PID} >/dev/null; then
				# the agent is not running, start it
				>&2 echo "Starting SSH agent, since it's not running; this can take a moment"
				_ssh_start_agent "${ssh_pid_file}" "${SSH_AUTH_SOCK}"
				>&2 echo "Started ssh-agent with '$SSH_AUTH_SOCK'"
			fi
		fi
	fi
	export SSH_AGENT_PID
	export SSH_AUTH_SOCK
}
