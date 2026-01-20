#!/usr/bin/env bash
# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# Generic configuration
#------------------------------------------------
if [[ -z "$XDG_RUNTIME_DIR" ]]; then
	export XDG_RUNTIME_DIR=/run/user/$UID
	if [[ ! -d "$XDG_RUNTIME_DIR" ]]; then
		export XDG_RUNTIME_DIR=/tmp/$USER-runtime
		if [[ ! -d "$XDG_RUNTIME_DIR" ]]; then
			mkdir -m 0700 "$XDG_RUNTIME_DIR"
		fi
	fi
fi

if [[ "$(which nvim)" == "" ]]; then
	export EDITOR="vim"
else
	export EDITOR="nvim"
fi

export ZK_NOTEBOOK_DIR="${HOME}/brain"
# Bash It configuration
#------------------------------------------------
# Path to the bash it configuration
export BASH_IT="${HOME}/.bash_it"

# Google Cloud configuration
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

# Don't check mail when opening terminal.
unset MAILCHECK

# Set this to false to turn off version control status checking within the prompt for all themes
export SCM_CHECK=true

# Load Bash It
source "${BASH_IT}/bash_it.sh"
source "${BASH_IT}/custom/devextension.bash"
source "${BASH_IT}/custom/ssh-agent-systemd.bash"
export BASH_IT_THEME=""

# Python tools configuration
#------------------------------------------------

# ssh-agent start
#------------------------------------------------
ssh_start_agent

export PATH=${PATH}:/usr/local/bin
if command -v zoxide >/dev/null; then
	eval "$(zoxide init bash)"
fi

export PATH=$PATH:$HOME/bin
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:"$(yarn global bin)"

# Starship configuration
#------------------------------------------------
# Starship init
eval "$(starship init bash)"
export PATH="$HOME/.local/bin:$PATH"

# Source local machine-specific overrides (not in git)
if [ -f ~/.bashrc.local ]; then
    source ~/.bashrc.local
fi
