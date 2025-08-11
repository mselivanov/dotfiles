#!/usr/bin/env bash

# Systemd SSH Agent Management
# Replaces the manual ssh-agent management with systemd user services

function ssh_systemd_init() {
    # Check if systemd user services are available
    if ! command -v systemctl >/dev/null 2>&1; then
        echo "systemctl not found. Falling back to manual SSH agent management." >&2
        return 1
    fi

    # Enable and start SSH agent service if not already running  
    if ! systemctl --user is-active --quiet ssh-agent.service; then
        systemctl --user enable ssh-agent.service >/dev/null 2>&1
        systemctl --user start ssh-agent.service >/dev/null 2>&1
    fi

    # Set SSH_AUTH_SOCK from systemd environment if available
    if systemctl --user show-environment | grep -q SSH_AUTH_SOCK; then
        eval "$(systemctl --user show-environment | grep SSH_AUTH_SOCK)"
        export SSH_AUTH_SOCK
    else
        # Fallback to runtime directory path
        export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"
    fi

    # Verify the socket is working
    if ! ssh-add -l >/dev/null 2>&1; then
        echo "SSH agent not responding. Restarting service..." >&2
        systemctl --user restart ssh-agent.service
        sleep 1
    fi
}

function ssh_systemd_add_keys() {
    # Add SSH keys if agent is running and no keys are loaded
    if ssh-add -l >/dev/null 2>&1; then
        local key_count=$(ssh-add -l 2>/dev/null | wc -l)
        if [ "$key_count" -eq 0 ]; then
            # Auto-add default keys
            ssh-add 2>/dev/null || true
        fi
    fi
}

function ssh_systemd_status() {
    echo "SSH Agent Systemd Status:"
    echo "========================="
    echo "Service status: $(systemctl --user is-active ssh-agent.service)"
    echo "SSH_AUTH_SOCK: $SSH_AUTH_SOCK"
    echo "Loaded keys:"
    ssh-add -l 2>/dev/null || echo "  No keys loaded or agent not accessible"
}


function ssh_start_agent() {
    ssh_systemd_init
    ssh_systemd_add_keys
}
