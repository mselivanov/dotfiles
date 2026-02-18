#!/usr/bin/env zsh
# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ── XDG Runtime Dir ────────────────────────────────────────────────────────────
if [[ -z "$XDG_RUNTIME_DIR" ]]; then
  export XDG_RUNTIME_DIR=/run/user/$UID
  if [[ ! -d "$XDG_RUNTIME_DIR" ]]; then
    export XDG_RUNTIME_DIR=/tmp/$USER-runtime
    mkdir -m 0700 -p "$XDG_RUNTIME_DIR"
  fi
fi

# ── Editor ─────────────────────────────────────────────────────────────────────
if command -v nvim &>/dev/null; then
  export EDITOR="nvim"
  alias pde="nvim"
else
  export EDITOR="vim"
fi

# ── Env / Personal ─────────────────────────────────────────────────────────────
export REPOSITORY_ROOT="${HOME}/repo"
export ZK_NOTEBOOK_DIR="${HOME}/brain"
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

# ── PATH ───────────────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH"

# ── Zinit bootstrap ────────────────────────────────────────────────────────────
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "$ZINIT_HOME/zinit.zsh"

# ── Plugins ────────────────────────────────────────────────────────────────────
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-history-substring-search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# ── Completions ────────────────────────────────────────────────────────────────
autoload -Uz compinit add-zsh-hook
compinit
zinit cdreplay -q

# uv shell completions
if command -v uv &>/dev/null; then
  eval "$(uv generate-shell-completion zsh)"
fi

# ── History ────────────────────────────────────────────────────────────────────
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# ── Options ────────────────────────────────────────────────────────────────────
setopt AUTO_CD
setopt CORRECT
setopt NO_BEEP

# ── Completion styling ─────────────────────────────────────────────────────────
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}=A-Z'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ── zoxide ─────────────────────────────────────────────────────────────────────
# --cmd cd shadows built-in cd so existing muscle memory works
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh --cmd cd)"
fi

# ── ripgrep ────────────────────────────────────────────────────────────────────
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"

# ── uv ─────────────────────────────────────────────────────────────────────────
export UV_PYTHON_PREFERENCE=managed
export UV_LINK_MODE=hardlink

# Auto-activate .venv when entering a project directory (uv-compatible)
_uv_activate_venv() {
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/.venv/bin/activate" ]]; then
      if [[ "$VIRTUAL_ENV" != "$dir/.venv" ]]; then
        source "$dir/.venv/bin/activate"
      fi
      return
    fi
    dir="$(dirname "$dir")"
  done
  [[ -n "$VIRTUAL_ENV" ]] && deactivate 2>/dev/null
}
add-zsh-hook chpwd _uv_activate_venv
_uv_activate_venv

# ── SSH agent ──────────────────────────────────────────────────────────────────
# Reuse existing agent or start a new one (mirrors ssh-agent-systemd from bash_it)
# if [[ -z "$SSH_AUTH_SOCK" ]]; then
#   if command -v systemctl &>/dev/null && systemctl --user is-active ssh-agent &>/dev/null; then
#     export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
#   else
#     eval "$(ssh-agent -s)" &>/dev/null
#   fi
# fi

# ── Aliases — core ─────────────────────────────────────────────────────────────
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias grep='grep --color=auto'

# bat (replaces cat) — same fallback logic as your custom_aliases.bash
if command -v bat &>/dev/null; then
  alias cat='bat'
elif command -v batcat &>/dev/null; then
  alias cat='batcat'
fi

# fd (prefer fd-find on distros that package it as fdfind)
if command -v fdfind &>/dev/null; then
  alias fd='fdfind'
fi

# ── Aliases — git ──────────────────────────────────────────────────────────────
alias gblsa='git branch --list --all'
alias gblsl='git branch --list'
alias gblsr='git branch --list --remotes'
alias gfd='git fetch origin dev:dev'
alias gur='git add . && git commit && git push --set-upstream origin $(git symbolic-ref --short HEAD)'
alias gxsm='git switch main && git pull'

# ── Aliases — ripgrep ──────────────────────────────────────────────────────────
alias rg='rg --smart-case'
alias rgh='rg --hidden'
alias rgp='rg --type py'

# ── Aliases — uv ───────────────────────────────────────────────────────────────
alias uvs='uv sync'
alias uvr='uv run'
alias uva='uv add'

# ── Prompt — Starship ──────────────────────────────────────────────────────────
# Your existing starship.toml works with zsh unchanged
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

# ── Local overrides ────────────────────────────────────────────────────────────
# Machine-specific config not tracked in git (mirrors your .bashrc.local pattern)
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
