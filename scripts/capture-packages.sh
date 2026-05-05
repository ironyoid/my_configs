#!/usr/bin/env bash
# Refresh packages/*.txt from the current host's pacman + systemd state.
# Run before `dotsync` if you've installed/removed packages worth tracking.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

pacman -Qqen > packages/pacman-explicit.txt
pacman -Qqem > packages/aur-explicit.txt
systemctl list-unit-files --state=enabled --no-legend \
    | awk '{print $1}' \
    | grep -E '\.(service|timer|socket)$' \
    > packages/services.txt

echo "Updated packages/*.txt:"
wc -l packages/*.txt
