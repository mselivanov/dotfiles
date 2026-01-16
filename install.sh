#!/usr/bin/env bash

# Install dotfiles using GNU stow
stow --restow bash tmux starship nvim bash_it zk systemd

# Setup systemd user services for SSH agent
# setup_systemd_ssh_agent() {
#     echo "Setting up systemd SSH agent services..."
#     
#     # Reload systemd user daemon to pick up new services
#     systemctl --user daemon-reload
#     
#     # Enable and start SSH agent service
#     systemctl --user enable ssh-agent.service
#     systemctl --user start ssh-agent.service
#     
#     # Check if service is running
#     if systemctl --user is-active --quiet ssh-agent.service; then
#         echo "✓ SSH agent service enabled and started"
#     else
#         echo "⚠ SSH agent service failed to start"
#         return 1
#     fi
#     
#     echo "✓ Systemd SSH agent setup complete"
#     echo "  Run 'ssh_systemd_status' to check status"
#     echo "  Run 'ssh-add' to add your SSH keys"
# }
# 
# # Run systemd setup
# if command -v systemctl >/dev/null 2>&1; then
#     setup_systemd_ssh_agent
# else
#     echo "⚠ systemctl not found - SSH agent will use legacy management"
# fi

echo "Dotfiles installation complete!"
echo "Please restart your shell or run: source ~/.bashrc"
