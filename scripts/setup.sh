#!/bin/sh

set -e

[ "$(id -u)" -eq 0 ] || { echo "This script must be run as root."; exit 1; }

./neovim
./cursor
