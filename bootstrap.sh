#!/bin/sh

set -eu

case "$(uname -s)" in
  Darwin) ;;
  *) echo "bootstrap.sh targets macOS only." >&2; exit 1 ;;
esac

basedir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

if git -C "$basedir" remote get-url origin >/dev/null 2>&1; then
    git -C "$basedir" pull --ff-only origin main \
        || echo "warn: git pull failed, continuing with the local checkout" >&2
fi

if ! xcode-select -p >/dev/null 2>&1; then
    echo "==> Installing Xcode Command Line Tools"
    xcode-select --install
    echo "Finish the GUI installer, then re-run this script." >&2
    exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
    echo "==> Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
else
    echo "brew not on PATH after install" >&2
    exit 1
fi

echo "==> brew bundle: programs"
brew bundle --file "$basedir/setup/programs"

if [ "${1:-}" = "--job" ]; then
    echo "==> brew bundle: programs-job"
    brew bundle --file "$basedir/setup/programs-job"
fi

echo "==> Linking dotfiles"
"$basedir/setup/links.sh"

echo "==> oh-my-zsh"
"$basedir/setup/ohmyzsh.sh"

cat <<'MSG'

Done. Left to do by hand:
  - chsh -s /opt/homebrew/bin/zsh   to use the brew zsh over the system one
  - configure Secretive SSH keys
  - open nvim once; vim.pack installs from nvim/nvim-pack-lock.json and
    mason installs the LSPs and formatters
MSG
