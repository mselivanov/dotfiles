Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
$ScriptDir=Split-Path ($MyInvocation.MyCommand.Path) -Parent
New-Item -Path "$HOME/.bashrc" -ItemType SymbolicLink -Target "$ScriptDir\bash\.bashrc" -Force
