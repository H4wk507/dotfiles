#!/bin/sh

set -eu

case "$(uname -s)" in
  Darwin) ;;
  *) echo "links.sh targets macOS only." >&2; exit 1 ;;
esac

basedir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

mkdir -p "$HOME/.config" "$HOME/.config/borgmatic" "$HOME/.agents" "$HOME/.local/bin" "$HOME/.cache/zsh"
mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"

link() {
    src="$basedir/$1"
    dest="$2"

    if [ ! -e "$src" ]; then
        echo "skip  $dest (no $src)" >&2
        return 0
    fi

    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        echo "ok    $dest"
        return 0
    fi

    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        backup="$dest.backup.$(date +%Y%m%d%H%M%S)"
        mv "$dest" "$backup"
        echo "moved $dest -> $backup"
    fi

    ln -sfn "$src" "$dest"
    echo "link  $dest -> $src"
}

link bash/bashrc        "$HOME/.bashrc"
link bash/profile        "$HOME/.profile"
link git/gitconfig       "$HOME/.gitconfig"
link git/gitconfig-job   "$HOME/.gitconfig-job"
link vim/vimrc          "$HOME/.vimrc"
link zsh/zshrc          "$HOME/.zshrc"
link zsh/zsh            "$HOME/.zsh"
link tmux/tmux.conf     "$HOME/.tmux.conf"
link ssh/config          "$HOME/.ssh/config"
link newsboat           "$HOME/.newsboat"
link nvim               "$HOME/.config/nvim"
link ghostty            "$HOME/.config/ghostty"
link skills             "$HOME/.agents/skills"
link bin                "$HOME/bin"
link backups/config.yaml "$HOME/.config/borgmatic/config.yaml"
