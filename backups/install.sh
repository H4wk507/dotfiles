#!/bin/sh

# Installs the root-owned half of the backup setup. Run with sudo.

set -eu

case "$(uname -s)" in
  Darwin) ;;
  *) echo "install.sh targets macOS only." >&2; exit 1 ;;
esac

[ "$(id -u)" -eq 0 ] || { echo "Run this with sudo." >&2; exit 1; }

basedir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
label=com.hxwk.borgbackup
wrapper=/usr/local/bin/borg-wrapper

if launchctl print "system/$label" 2>/dev/null | grep -q "state = running"; then
    echo "$label is running right now. Wait for it to finish, then re-run." >&2
    exit 1
fi

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

[ -d /usr/local/bin ] || install -d -m 755 -o root -g wheel /usr/local/bin

# Rebuilding the wrapper changes its signature and so invalidates its
# FDA grant.
rebuilt=no
if [ ! -x "$wrapper" ] || [ "$basedir/borg-wrapper.c" -nt "$wrapper" ]; then
    echo "==> Building borg-wrapper"
    cc -o "$tmpdir/borg-wrapper" "$basedir/borg-wrapper.c"
    codesign --force --sign - "$tmpdir/borg-wrapper"
    install -m 700 -o root -g wheel "$tmpdir/borg-wrapper" "$wrapper"
    rebuilt=yes
else
    echo "==> borg-wrapper is current, leaving it and its FDA grant alone"
fi

echo "==> Installing borg-backup.sh"
install -m 700 -o root -g wheel "$basedir/borg-run.sh" /usr/local/bin/borg-backup.sh

echo "==> Installing log rotation"
install -m 644 -o root -g wheel "$basedir/borgbackup.newsyslog.conf" /etc/newsyslog.d/borgbackup.conf

echo "==> Installing LaunchDaemon"
install -m 644 -o root -g wheel "$basedir/$label.plist" "/Library/LaunchDaemons/$label.plist"
launchctl bootout "system/$label" 2>/dev/null || true
launchctl bootstrap system "/Library/LaunchDaemons/$label.plist"

cat <<'MSG'

Done. Left to do by hand:
  - repo passphrase in /Library/Keychains/System.keychain
  - authorized_keys on the Storage Box
  - snapshot plan in the Hetzner console
  - wake schedule:  sudo pmset repeat wakeorpoweron MTWRFSU 03:30:00
MSG

if [ "$rebuilt" = yes ]; then
    cat <<'MSG'
  - Full Disk Access for /usr/local/bin/borg-wrapper. The wrapper was just
    rebuilt, so an existing grant no longer matches it: remove the old entry
    and add it again.
MSG
fi

cat <<'MSG'

Test run:  sudo launchctl kickstart system/com.hxwk.borgbackup
MSG
