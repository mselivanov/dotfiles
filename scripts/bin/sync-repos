#!/usr/bin/env bash
# Sync dotfiles and knowledge base repositories

set -euo pipefail

LOG_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/sync-repos.log"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
KNOWLEDGE_DIR="${KNOWLEDGE_DIR:-$HOME/brain}"

mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

sync_repo() {
    local repo_path="$1"
    local repo_name="$2"
    
    if [[ ! -d "$repo_path" ]]; then
        log "⚠ $repo_name not found at $repo_path"
        return 1
    fi
    
    cd "$repo_path" || return 1
    
    if git pull --rebase && git push; then
        log "✓ $repo_name synced"
        return 0
    else
        log "✗ $repo_name sync failed"
        return 1
    fi
}

log "=== Sync started ==="

sync_repo "$DOTFILES_DIR" "Dotfiles"
sync_repo "$KNOWLEDGE_DIR" "Knowledge base"

log "=== Sync completed ==="
