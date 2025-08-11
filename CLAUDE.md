# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository managed with GNU Stow for organizing and deploying configuration files across Unix-like systems. The repository contains configurations for essential development tools and shell environments.

## Installation and Management

### Primary Commands

- **Install/Update all configurations**: `./install.sh`
  - Uses stow to symlink configurations: `stow --restow bash tmux starship nvim bash_it zk`
  
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

## Development Environment Architecture

### Shell Configuration Stack
1. **Bash** with Bash-it framework for enhanced shell features
2. **Starship** for fast, customizable shell prompt
3. **Zoxide** for smart directory navigation (if available)
4. **SSH agent management** with persistent session handling

### Key Environment Variables
- `EDITOR`: Automatically set to `nvim` if available, otherwise `vim`
- `ZK_NOTEBOOK_DIR`: Set to `${HOME}/brain` for note-taking
- `BASH_IT`: Points to `${HOME}/.bash_it`
- `XDG_RUNTIME_DIR`: Properly configured for runtime files

### Custom Bash Functions
Located in `bash_it/.bash_it/custom/`:

**devextension.bash**:
- `cleanup_nvim()`: Completely removes Neovim configuration and data
- `tmux_create_session(name)`: Creates new tmux session with proper setup
- `tmux_create_app_window(session, window, command, path)`: Adds windows to sessions
- `workon(env_code)`: Sources environment-specific initialization scripts

**ssh-agent-manage.bash**:
- `ssh_start_agent()`: Intelligent SSH agent management with persistence
- `ssh_init_files()`: Initializes SSH agent configuration files

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

## Development Workflow

### Environment Setup
When setting up a new development environment:
1. Clone this repository to `~/.dotfiles`
2. Run `./install.sh` to deploy all configurations
3. Source new shell configuration or restart terminal

### Working with Multiple Projects
Use the `workon <env_code>` function to load project-specific environments. Create initialization scripts at `~/.bash_it/custom/workon-<env_code>.sh` for each project.

### Tmux Session Management
Use the custom tmux functions for consistent session and window management across different development contexts.