export REPOSITORY_ROOT="${HOME}/repo"

# Google Cloud Commands
alias bqss='bq show --format prettyjson'

# Custom git aliases
alias gblsa='git branch --list --all'
alias gblsl='git branch --list'
alias gblsr='git branch --list --remotes'
alias gfd='git fetch origin dev:dev'

# CLI tools aliases
if [[ "x$(which fdfind 2>/dev/null)" != "x" ]]; then
	alias fd='fdfind'
else
	alias fd='find'
fi

if [[ "x$(which batcat 2>/dev/null)" != "x" ]]; then
	alias cat='batcat'
elif
	[[ "x$(which bat 2>/dev/null)" != "x" ]]
then
	alias cat='bat'
else
	alias cat='cat'
fi
# Remove alias for lf from bash_it
unalias lf

# Nvim aliases
alias pde="nvim"
