# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository managed with GNU Stow for organizing and deploying configuration files across Unix-like systems. The repository contains configurations for essential development tools and shell environments.

## Installation and Management

### Primary Commands

- **Install/Update all configurations**: `./install.sh`
  - Stows all packages: `bash tmux starship nvim bash_it zk systemd scripts`
  - Sets up systemd user services (SSH agent, repo sync timer)
  - Creates machine-specific config templates if needed

- **Check installation status**: `dotfiles-status` (shows stow packages, configs, systemd services)
- **Sync repositories**: `sync-repos` (manually sync dotfiles and knowledge base repos)
- **Manual stow management**: `stow <package_name>` (e.g., `stow nvim`)
- **Remove configurations**: `stow -D <package_name>`

### Package Structure

Each directory represents a stow package that mirrors the target filesystem structure:
- `bash/` → `~/.bashrc` and bash configurations
- `tmux/` → `~/.tmux.conf`
- `nvim/` → `~/.config/nvim/` (Neovim configuration)
- `starship/` → `~/.config/starship.toml` (shell prompt)
- `bash_it/` → `~/.bash_it/` (Bash framework customizations)
- `zk/` → `~/.config/zk/` (note-taking tool configuration)
- `systemd/` → `~/.config/systemd/user/` (user systemd services)
- `scripts/` → `~/bin/` (utility scripts)

### Machine-Specific Configurations

The repository uses a template system for machine-specific settings that aren't committed to git:
- `~/.bashrc.local` - Machine-specific bash configuration (sourced at end of .bashrc)
- `~/.config/nvim/local.lua` - Machine-specific Neovim settings
- `~/.tmux.conf.local` - Machine-specific tmux settings

Templates are located in `templates/` directory and copied during `./install.sh` if missing.

## Development Environment Architecture

### Shell Configuration Stack
1. **Bash** with Bash-it framework for enhanced shell features
2. **Starship** for fast, customizable shell prompt
3. **Zoxide** for smart directory navigation (if available)
4. **SSH agent** managed via systemd user service for persistence across sessions

### Key Environment Variables
- `EDITOR`: Automatically set to `nvim` if available, otherwise `vim`
- `ZK_NOTEBOOK_DIR`: Set to `${HOME}/brain` for note-taking
- `BASH_IT`: Points to `${HOME}/.bash_it`
- `XDG_RUNTIME_DIR`: Properly configured for runtime files
- `USE_GKE_GCLOUD_AUTH_PLUGIN`: Set to `True` for Google Cloud GKE authentication
- `PATH`: Extended with `~/bin`, `~/.local/bin`, and yarn global bin

### Custom Bash Functions
Located in `bash_it/.bash_it/custom/`:

**devextension.bash**:
- `cleanup_nvim()`: Completely removes Neovim configuration and data
- `tmux_create_session(name)`: Creates new tmux session with proper setup
- `tmux_create_app_window(session, window, command, path)`: Adds windows to sessions
- `workon(env_code)`: Sources environment-specific initialization scripts from `~/.bash_it/custom/workon-<env_code>.sh`

**ssh-agent-systemd.bash**:
- `ssh_start_agent()`: Initializes systemd-managed SSH agent (auto-called in .bashrc)
- `ssh_systemd_status()`: Shows SSH agent systemd service status and loaded keys
- `ssh_systemd_init()`: Low-level systemd SSH agent initialization
- `ssh_systemd_add_keys()`: Auto-adds default SSH keys if none loaded

## Neovim Configuration

### Architecture
- **Plugin manager**: Lazy.nvim
- **Configuration structure**: Modular Lua setup with separate files for:
  - `config/options.lua`: Editor options
  - `config/keymaps.lua`: Key mappings
  - `config/autocmds.lua`: Autocommands
  - `plugins/`: Individual plugin configurations

### Notable Plugins
- **claude-code.nvim**: Integrated Claude Code support with floating window interface
- **avante.nvim**: Currently commented out AI assistant plugin
- **nvim-tree.lua**: File explorer
- **telescope.nvim**: Fuzzy finder
- **toggleterm.lua**: Terminal integration
- **zk-nvim.lua**: Note-taking integration

## Tmux Configuration

### Key Bindings
- **Prefix**: `Ctrl-a` (instead of default Ctrl-b)
- **Split panes**: `prefix + |` (vertical), `prefix + -` (horizontal)
- **Navigation**: `prefix + h/j/k/l` (vim-style pane movement)
- **Resize**: `prefix + H/J/K/L` (vim-style pane resizing)
- **Reload config**: `prefix + r`

### Features
- Vi-mode copy/paste with `v` to select, `y` to copy
- 256 color support with RGB terminal overrides
- Activity monitoring and visual notifications
- Custom green/yellow color scheme

## Systemd Services

The repository includes systemd user services for automation:

### SSH Agent Service
- **Service**: `ssh-agent.service`
- **Purpose**: Persistent SSH agent across all terminal sessions
- **Commands**:
  - `ssh_systemd_status` - Check service status and loaded keys
  - `systemctl --user restart ssh-agent.service` - Restart if needed

### Repository Sync Timer
- **Timer**: `sync-repos.timer` (runs at 8:30 AM and 7:00 PM on weekdays)
- **Service**: `sync-repos.service`
- **Purpose**: Automatically pull and push changes to dotfiles and knowledge base repos
- **Commands**:
  - `sync-repos` - Manual sync
  - `systemctl --user list-timers sync-repos.timer` - Check next scheduled run
  - Logs: `~/.local/state/sync-repos.log`

## Development Workflow

### Environment Setup
When setting up a new development environment:
1. Clone this repository to `~/.dotfiles`
2. Run `./install.sh` to deploy all configurations
3. Edit machine-specific configs (`~/.bashrc.local`, `~/.config/nvim/local.lua`, `~/.tmux.conf.local`)
4. Restart terminal or run `source ~/.bashrc`

### Working with Multiple Projects
Use the `workon <env_code>` function to load project-specific environments. Create initialization scripts at `~/.bash_it/custom/workon-<env_code>.sh` for each project.

### Tmux Session Management
Use the custom tmux functions for consistent session and window management across different development contexts.