#!/bin/bash
# Env vars
export DKPI_VENV_ROOT=/c/venv/dkpi/
export REPOSITORY_ROOT=/c/repo
export GCLOUD_SDK_ROOT=/c/Programs/Google/Cloud\ SDK/google-cloud-sdk/
export CLOUDSDK_PYTHON=${GCLOUD_SDK_ROOT}/platform/bundledpython/python.exe
export PATH=${PATH}:${GCLOUD_SDK_ROOT}/bin

# Set up ssh keys
env=~/.ssh/agent.env

agent_load_env () { 
	test -f "$env" && . "$env" >| /dev/null ; 
}

agent_start () {
	(umask 077; ssh-agent >| "$env")
	. "$env" >| /dev/null ; 
}

agent_load_env

# agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2= agent not running
agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)

if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
	agent_start
	ssh-add ~/.ssh/id_ed25519 
	ssh-add ~/.ssh/id_ed25519_2
elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
	ssh-add ~/.ssh/id_ed25519 
	ssh-add ~/.ssh/id_ed25519_2
fi

unset env

# Common commands
alias q='exit'
alias c='clear'
alias lsl='ls -l'
alias lsa='ls -a'
alias sc='source ~/.bashrc'
alias ec='vim ~/.bashrc'
alias p='cat'
alias pd='pwd'
alias folders='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'

# Navigation commands
alias nh='cd ~'
alias nr='cd /'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'


alias dc='docker container'
alias dcs='docker container start'
alias dcl='docker container logs'
alias dcls='docker container ls --all'

# Git Commands
alias gs='git status'
alias ga='git add .'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'
alias gf='git fetch'
alias gnb='git checkout -b'
alias gck='git checkout'
alias gckm='git checkout master'
alias gckmp='git checkout master && git pull'
alias gac='ga && gc'
alias gacp='ga && gc && gp'
alias gbls='git branch -vv'

# Python Commands
alias pws='python -m http.server 8000'

# Google Cloud COmmands
alias bq='bq.cmd'
alias bqss='bq show --format prettyjson'

# Project DKPI aliases
export PRJ_DKPI_ROOT="${REPOSITORY_ROOT}/bayc-alec"
export DKPI_PROD_PROJECT="bayer-ch-230109"
export DKPI_DEV_PROJECT="bayer-ch-global-dev"
alias cddk='cd ${PRJ_DKPI_ROOT}'
alias dktest='${PRJ_DKPI_ROOT}/build/build.sh unittests'
alias dkcov='${PRJ_DKPI_ROOT}/build/build.sh coverage'
alias dkbuild='${PRJ_DKPI_ROOT}/build/build.sh build'
alias dkenv="source ${DKPI_VENV_ROOT}/Scripts/activate"
alias dkroot="cd ${PRJ_DKPI_ROOT}"
alias dkchg="cd ${PRJ_DKPI_ROOT}/dags/schema/changelog/"
alias dkwai="gcloud config get-value project"
alias dkprod="gcloud config set project ${DKPI_PROD_PROJECT}"
alias dkdev="gcloud config set project ${DKPI_DEV_PROJECT}"
