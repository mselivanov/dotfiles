export REPOSITORY_ROOT="${HOME}/repo"

# Google Cloud Commands
alias bqss='bq show --format prettyjson'

# Custom git aliases
alias grls='gco master && gpl && gco release && gpl && gm master && gp'
alias gblsa='git branch --list --all'
alias gblsl='git branch --list'
alias gblsr='git branch --list --remotes'

# CLI tools aliases
alias fd='fdfind'
alias cat='batcat'
# Remove alias for lf from bash_it
unalias lf


# Project DKPI aliases
export PRJ_DKPI_ROOT="${REPOSITORY_ROOT}/bayc-alec"
export DKPI_PROD_PROJECT="bayer-ch-230109"
export DKPI_DEV_PROJECT="bayer-ch-global-dev"
alias cddk='cd ${PRJ_DKPI_ROOT}'
alias dkroot="cd ${PRJ_DKPI_ROOT}"
alias dkchg="cd ${PRJ_DKPI_ROOT}/cloud/changelog/"
alias dkwai="gcloud config get-value project"
alias dkprod="gcloud config set project ${DKPI_PROD_PROJECT}"
alias dkdev="gcloud config set project ${DKPI_DEV_PROJECT}"
