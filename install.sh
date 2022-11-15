#!/usr/bin/env bash
stow bash tmux starship nvim
nvim +'PlugInstall --sync' +qall
nvim +'CocInstall -sync coc-prettier coc-json coc-pyright coc-git coc-spell-checker' +qall
