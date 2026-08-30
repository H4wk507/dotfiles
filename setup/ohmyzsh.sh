#!/bin/sh

set -eu

ZSH_DIR="$HOME/.oh-my-zsh"
CUSTOM="${ZSH_CUSTOM:-$ZSH_DIR/custom}"

if [ -d "$ZSH_DIR" ]; then
    echo "ok    oh-my-zsh"
else
    echo "==> Installing oh-my-zsh"
    KEEP_ZSHRC=yes RUNZSH=no CHSH=no \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

clone_plugin() {
    dir="$CUSTOM/plugins/$1"
    if [ -d "$dir" ]; then
        echo "ok    $1"
    else
        echo "==> Cloning $1"
        git clone --depth 1 "$2" "$dir"
    fi
}

clone_plugin zsh-autosuggestions     https://github.com/zsh-users/zsh-autosuggestions
clone_plugin you-should-use          https://github.com/MichaelAquilina/zsh-you-should-use
clone_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting
