#!/bin/bash
LOG="/tmp/betterlockscreen-debug.log"

echo "=== $(date) ===" >> "$LOG"
echo "ARGS: $*" >> "$LOG"
echo "DISPLAY=$DISPLAY" >> "$LOG"
echo "XAUTHORITY=$XAUTHORITY" >> "$LOG"
echo "DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS" >> "$LOG"
echo "XDG_SESSION_ID=$XDG_SESSION_ID" >> "$LOG"
echo "PATH=$PATH" >> "$LOG"
echo "HOME=$HOME" >> "$LOG"
echo "--- xkb-switch output ---" >> "$LOG"
xkb-switch -l >> "$LOG" 2>&1
echo "--- setxkbmap query ---" >> "$LOG"
setxkbmap -query >> "$LOG" 2>&1
echo "--- i3lock-color version ---" >> "$LOG"
i3lock-color --version >> "$LOG" 2>&1 || i3lock --version >> "$LOG" 2>&1
echo "=========================" >> "$LOG"

# Run betterlockscreen with bash tracing, capture the i3lock command
exec bash -x /usr/bin/betterlockscreen "$@" 2>> "$LOG"
