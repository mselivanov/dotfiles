# Custom git aliases
alias gblsa='git branch --list --all'
alias gblsl='git branch --list'
alias gblsr='git branch --list --remotes'
alias gfd='git fetch origin dev:dev'
alias gur='git add . && git commit && git push --set-upstream origin $(git symbolic-ref --short HEAD)'

# CLI tools aliases
if [[ "x$(which fd 2>/dev/null)" != "x" ]]; then
	alias fd='fd'
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

alias ls='exa'
alias ll='exa -l'
alias la='exa -la'
alias lt='exa --tree'

alias find='fd'
alias grep='rg'
# Remove alias for lf from bash_it
unalias lf

# Nvim aliases
alias pde="nvim"

alias docker='podman'  # Docker compatibility
alias podman-clean='podman system prune -a --volumes'

alias ports='sudo netstat -tulanp'
