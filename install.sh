#!/usr/bin/env bash
stow bash tmux starship vim
vim +'PlugInstall --sync' +qall
vim +'CocInstall -sync coc-prettier coc-json coc-pyright coc-git coc-spell-checker' +qall
stow nvim 
