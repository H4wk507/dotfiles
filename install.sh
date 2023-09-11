#!/bin/sh

git pull origin main

basedir=$(dirname "$0")
cd "$basedir" || { echo "Could not cd to $basedir" >&2; exit 1; }

# Create symlinks from HOME directory to dotfiles directory
ln -svn "$PWD/bash/bashrc"    "$HOME/.bashrc"
ln -svn "$PWD/bash/profile"   "$HOME/.profile"
ln -svn "$PWD/git/gitconfig"  "$HOME/.gitconfig"
ln -svn "$PWD/vim/vimrc"      "$HOME/.vimrc"
ln -svn "$PWD/zsh/zshrc"      "$HOME/.zshrc"
ln -svn "$PWD/nvim"           "$HOME/.config/nvim"
ln -svn "$PWD/zsh/zsh"        "$HOME/.zsh"
ln -svn "$PWD/tmux/tmux.conf" "$HOME/.tmux.conf"
ln -svn "$PWD/ssh/config"     "$HOME/.ssh/config"
# ln -svn "$PWD/newsboat"       "$HOME/.newsboat"
