#!/usr/bin/env bash

# If not running interactively, don't do anything
case $- in
  *i*) ;;
    *) return;;
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


# Bash It configuration
#------------------------------------------------
# Path to the bash it configuration
export BASH_IT="/home/maksim/.bash_it"
export BASH_IT_THEME='modern'

# Don't check mail when opening terminal.
unset MAILCHECK

# Set this to false to turn off version control status checking within the prompt for all themes
export SCM_CHECK=true

# Load Bash It
source "${BASH_IT}/bash_it.sh"

# Python tools configuration
#------------------------------------------------
# Pyenv init
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Virualenvs location
export WORKON_HOME=~/.virtualenvs

# Starship configuration
#------------------------------------------------
# Starship init
eval "$(starship init bash)"

