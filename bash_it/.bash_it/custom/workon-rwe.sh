#!/bin/env bash

session_name="ide-rwe"

tmux_create_session "${session_name}"

if [[ $? = 0 ]]; then
  tmux_create_app_window "${session_name}" "eeo-it" "exec nvim" "/home/vagrant/repo/EEO-IT"
  tmux_create_app_window "${session_name}" "eeo-it-cli" "" "/home/vagrant/repo/EEO-IT"
  tmux_create_app_window "${session_name}" "eeo-us" "exec nvim" "/home/vagrant/repo/EEO_US"
  tmux_create_app_window "${session_name}" "eeo-us-cli" "" "/home/vagrant/repo/EEO_US"
  tmux_create_app_window "${session_name}" "btop" "exec btop" "/home/vagrant/repo/EEO-IT"
  tmux_create_app_window "${session_name}" "scratchpad" "" "/home/vagrant/repo/EEO-IT"
  tmux_post_cleanup "${session_name}"
  tmux select-window -t "${session_name}":1
fi
tmux attach -t "${session_name}"
