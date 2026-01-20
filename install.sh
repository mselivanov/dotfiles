#!/usr/bin/env bash

# Install dotfiles using GNU stow
stow --restow bash tmux starship nvim bash_it zk systemd scripts

# Setup machine-specific configs
setup_local_configs() {
    echo ""
    echo "=== Machine-specific configuration setup ==="
    
    local templates_dir="$(dirname "$0")/templates"
    local needs_setup=false
    
    # Check if local configs exist
    if [ ! -f ~/.bashrc.local ]; then
        echo "  bashrc.local not found"
        needs_setup=true
    fi
    
    if [ ! -f ~/.config/nvim/local.lua ]; then
        echo "  nvim local.lua not found"
        needs_setup=true
    fi
    
    if [ ! -f ~/.tmux.conf.local ]; then
        echo "  tmux.conf.local not found"
        needs_setup=true
    fi
    
    if [ "$needs_setup" = true ]; then
        echo ""
        echo "Would you like to create machine-specific config files from templates? (y/N)"
        read -r response
        
        if [[ "$response" =~ ^[Yy]$ ]]; then
            [ ! -f ~/.bashrc.local ] && cp "$templates_dir/bashrc.local.example" ~/.bashrc.local && \
                echo "  ✓ Created ~/.bashrc.local (edit for this machine)"
            
            [ ! -f ~/.config/nvim/local.lua ] && cp "$templates_dir/nvim-local.lua.example" ~/.config/nvim/local.lua && \
                echo "  ✓ Created ~/.config/nvim/local.lua (edit for this machine)"
            
            [ ! -f ~/.tmux.conf.local ] && cp "$templates_dir/tmux.conf.local.example" ~/.tmux.conf.local && \
                echo "  ✓ Created ~/.tmux.conf.local (edit for this machine)"
            
            echo ""
            echo "  Edit these files to customize for this machine:"
            echo "    - ~/.bashrc.local"
            echo "    - ~/.config/nvim/local.lua"
            echo "    - ~/.tmux.conf.local"
        else
            echo "  Skipped. You can manually copy templates from: $templates_dir"
        fi
    else
        echo "  ✓ Machine-specific configs already exist"
    fi
}

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

# Setup local configs
setup_local_configs

echo "Dotfiles installation complete!"
echo "Please restart your shell or run: source ~/.bashrc"
