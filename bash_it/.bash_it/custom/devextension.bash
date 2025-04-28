#!/usr/bin/env bash

TMP_WINDOW_NAME="tmp_start_window"

function cleanup_nvim() {
	rm -rf ~/.config/nvim
	rm -rf ~/.local/share/nvim
	rm -rf ~/.cache/nvim
}


function tmux_create_session() {
    local session_name=$1
    
    # Check if session already exists
    tmux has-session -t $session_name 2>/dev/null
    
    if [[ $? != 0 ]]; then
        # Create a new session with a window named "main"
	tmux set-option -t $session_name base-index 0
        tmux new-session -d -s $session_name -n "${TMP_WINDOW_NAME}"
        echo "Created new tmux session: $session_name"
	return 0
    else
        echo "Session $session_name already exists"
	return 1
    fi
}

function tmux_post_cleanup() {
  local session_name=$1
  tmux kill-window -t ${session_name}:${TMP_WINDOW_NAME}
}

function tmux_create_app_window() {
    local session_name=$1
    local window_name=$2
    local exec_name=$3
    local start_path=$4
    local command=""
    

    if [[ "$start_path" != "" ]];
    then
      command="cd ${start_path} && "
    fi

    if [[ "$exec_name" != "" ]];
    then
      command="${command} ${exec_name}"
    else
      command="${command} exec bash"
    fi
    # Create a new window running app
    tmux new-window -d -t $session_name: -n $window_name "${command}"
    echo "Created $window_name window"
}

function workon() {
  _env_code="$1"
  _init_file_path="${BASH_IT}/custom/workon-${_env_code}.sh"
  if [[ -f "${_init_file_path}" ]]; then
    source "${_init_file_path}"
  else
    printf "Can't initialize environment: ${_env_code}\n"
    printf "Path does not exist: ${_init_file_path}"
  fi
}
