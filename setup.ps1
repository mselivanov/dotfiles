Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
$ScriptDir=Split-Path ($MyInvocation.MyCommand.Path) -Parent
New-Item -Path "$HOME/.bashrc" -ItemType SymbolicLink -Target "$ScriptDir\bash\.bashrc" -Force
New-Item -Path "$HOME/_vimrc" -ItemType SymbolicLink -Target "$ScriptDir\vim\_vimrc" -Force
git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
