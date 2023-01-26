#!/usr/bin/env bash

basedir=$(dirname "$0")
cd "$basedir" || { echo "Could not cd to $basedir" >&2; exit 1; }

# Create symlinks from HOME directory to dotfiles directory
ln -sv "$PWD/bashrc" "$HOME/.bashrc"
ln -sv "$PWD/profile" "$HOME/.profile"
ln -sv "$PWD/gitconfig" "$HOME/.gitconfig"
ln -sv "$PWD/vimrc" "$HOME/.vimrc"
ln -sv "$PWD/zshrc" "$HOME/.zshrc"
ln -sv "$PWD/init.vim" "$HOME/.config/nvim/init.vim"
