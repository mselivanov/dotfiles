#!/usr/bin/env bash
stow bash tmux vim starship
vim +'PlugInstall --sync' +qall
vim +'CocInstall -sync coc-prettier coc-json coc-pyright coc-git coc-spell-checker' +qall
stow nvim
