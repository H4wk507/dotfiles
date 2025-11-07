#!/bin/sh

set -e

sudo apt update
sudo apt install ffmpeg mpv tmux

./neovim
./cursor
