#!/usr/bin/env bash

# Install dotfiles using GNU stow
stow --restow bash tmux starship nvim bash_it zk systemd scripts

# Setup systemd user services for SSH agent
setup_systemd_ssh_agent() {
    echo "Setting up systemd SSH agent services..."
    
    # Reload systemd user daemon to pick up new services
    systemctl --user daemon-reload
    
    # Enable and start SSH agent service
    systemctl --user enable ssh-agent.service
    systemctl --user start ssh-agent.service
    
    # Check if service is running
    if systemctl --user is-active --quiet ssh-agent.service; then
        echo "✓ SSH agent service enabled and started"
    else
        echo "⚠ SSH agent service failed to start"
        return 1
    fi
    
    echo "✓ Systemd SSH agent setup complete"
    echo "  Run 'ssh_systemd_status' to check status"
    echo "  Run 'ssh-add' to add your SSH keys"
}

# Setup repo sync timer
setup_sync_repos_timer() {
    echo "Setting up repo sync timer..."
    
    systemctl --user daemon-reload
    systemctl --user enable sync-repos.timer
    systemctl --user start sync-repos.timer
    
    if systemctl --user is-active --quiet sync-repos.timer; then
        echo "✓ Repo sync timer enabled (runs 8:30 AM and 7:00 PM weekdays)"
        echo "  Run 'systemctl --user list-timers sync-repos.timer' to check schedule"
        echo "  Run 'sync-repos' manually anytime to sync"
    else
        echo "⚠ Repo sync timer failed to start"
        return 1
    fi
}

# Run systemd setup
if command -v systemctl >/dev/null 2>&1; then
    setup_systemd_ssh_agent
    setup_sync_repos_timer
else
    echo "⚠ systemctl not found - systemd services will not be configured"
fi

echo "Dotfiles installation complete!"
echo "Please restart your shell or run: source ~/.bashrc"
