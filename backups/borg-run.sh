#!/bin/bash

# install.sh puts this in /usr/local/bin/borg-backup.sh
#
# It only runs as root, so don't use relative stuff like $HOME

set -euo pipefail

MNT=/private/tmp/borg-snap  # same path as working_directory in config.yaml
CONFIG=/Users/hxwk/.config/borgmatic/config.yaml

[ "$(id -u)" -eq 0 ] || { echo "Must run as root." >&2; exit 1; }

# Hold the machine awake from here until this script exits
/usr/bin/caffeinate -s -w $$ &

umount "$MNT" 2>/dev/null || true

SNAP=$(tmutil localsnapshot / | awk -F': ' '/Created local snapshot/ {print $NF}') || true
[ -n "$SNAP" ] || { echo "Couldn't create a snapshot." >&2; exit 1; }

cleanup() {
    umount "$MNT" 2>/dev/null || true
    tmutil deletelocalsnapshots "$SNAP" >/dev/null 2>&1 || true
}
trap cleanup EXIT

mkdir -p "$MNT"
mount_apfs -o ro,nobrowse -s "com.apple.TimeMachine.${SNAP}.local" /System/Volumes/Data "$MNT"

[ -d "$MNT/Users/hxwk" ] || { echo "Empty snapshot. Stopping." >&2; exit 1; }

/opt/homebrew/bin/borgmatic --config "$CONFIG" --verbosity 1
