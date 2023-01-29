#!/usr/bin/env bash

git pull origin main

basedir=$(dirname "$0")
cd "$basedir" || { echo "Could not cd to $basedir" >&2; exit 1; }

# Create symlinks from HOME directory to dotfiles directory
ln -sv "$PWD/bash/bashrc" "$HOME/.bashrc"
ln -sv "$PWD//bash/profile" "$HOME/.profile"
ln -sv "$PWD/git/gitconfig" "$HOME/.gitconfig"
ln -sv "$PWD/vim/vimrc" "$HOME/.vimrc"
ln -sv "$PWD/zsh/zshrc" "$HOME/.zshrc"
# need to treat directories differently
if [[ ! -L "$HOME/.zsh" ]]; then
    ln -sv "$PWD/zsh/zsh" "$HOME/.zsh"
fi
if [[ ! -L "$HOME/.config/nvim" ]]; then
    ln -sv "$PWD/nvim" "$HOME/.config/nvim"
fi
