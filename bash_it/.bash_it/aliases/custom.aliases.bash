export REPOSITORY_ROOT=~/repo

# Google Cloud Commands
alias bq=bq
alias bqss='bq show --format prettyjson'
# Custom git aliases
alias grls='gco master && gpl && gco release && gm master && gp'
alias gblsa='git branch --list --all'
alias gblsl='git branch --list'
alias gblsr='git branch --list --remotes'



# Project DKPI aliases
export PRJ_DKPI_ROOT="${REPOSITORY_ROOT}/bayc-alec"
export DKPI_PROD_PROJECT="bayer-ch-230109"
export DKPI_DEV_PROJECT="bayer-ch-global-dev"
alias cddk='cd ${PRJ_DKPI_ROOT}'
alias dkroot="cd ${PRJ_DKPI_ROOT}"
alias dkchg="cd ${PRJ_DKPI_ROOT}/dags/schema/changelog/"
alias dkwai="gcloud config get-value project"
alias dkprod="gcloud config set project ${DKPI_PROD_PROJECT}"
alias dkdev="gcloud config set project ${DKPI_DEV_PROJECT}"
alias dklint="pylint --rcfile=${PRJ_DKPI_ROOT}/pylintrc ${PRJ_DKPI_ROOT}/src/digital_kpi" 
