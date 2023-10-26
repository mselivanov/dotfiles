#!/usr/bin/env bash

function cleanup_nvim() {
	rm -rf ~/.config/nvim
	rm -rf ~/.local/share/nvim
	rm -rf ~/.cache/nvim
}

function start_ide() {
	local _session_name="$1"
	local _project_path="$2"

	tmux has-session -t ${_session_name} 2>/dev/null
	if [[ $? != 0 ]]; then
		tmux new-session -s "${_session_name}" -d
		start_editor "${_session_name}" "${_project_path}" "editor" "0"
		tmux new-window -n console -t "${_session_name}"
		tmux send-keys -t "${_session_name}:2" "cd ${_project_path}" C-m
		tmux new-window -n scratchpad -t "${_session_name}"
		tmux send-keys -t "${_session_name}:3" "cd ${_project_path}" C-m
		tmux select-window -t 1
	fi
	tmux attach -t ${_session_name}
}

function start_editor() {
	local _session_name="$1"
	local _project_path="$2"
	local _window_name="$3"
	local _window_after_index="$4"

	tmux new-window -n "${_window_name}" -t "${_session_name}"
	tmux send-keys -t "${_session_name}" "cd ${_project_path}" C-m
	tmux send-keys -t "${_session_name}" "$EDITOR" C-m
}

function workon() {
	_env_code="$1"
	_init_file_path="${BASH_IT}/custom/workon-${_env_code}"
	if [[ -f "${_init_file_path}" ]]; then
		source "${_init_file_path}"
	else
		printf "Can't initialize environment: ${_env_code}\n"
		printf "Path does not exist: ${_init_file_path}"
	fi
}
