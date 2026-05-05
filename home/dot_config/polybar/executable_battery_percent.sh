#!/usr/bin/env bash
set -euo pipefail

BAT="${1:-BAT0}"
cap_file="/sys/class/power_supply/${BAT}/capacity"
show_file="${SHOW_FILE:-/tmp/polybar-battery-show-${BAT}}"
module_name="${BATTERY_MODULE:-battery}"
show_for="${SHOW_FOR:-5}"
runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

if [[ -z "${DBUS_SESSION_BUS_ADDRESS-}" && -S "$runtime_dir/bus" ]]; then
  export DBUS_SESSION_BUS_ADDRESS="unix:path=$runtime_dir/bus"
fi

if [[ ! -r "$cap_file" ]]; then
  exit 1
fi

capacity="$(cat "$cap_file")"
message="Battery: ${capacity}%"

date +%s > "$show_file"
if command -v polybar-msg >/dev/null 2>&1; then
  polybar-msg action "#${module_name}.hook.0" >/dev/null 2>&1 || true
  if command -v nohup >/dev/null 2>&1; then
    nohup sh -c "sleep \"$show_for\"; rm -f \"$show_file\"; polybar-msg action \"#${module_name}.hook.0\" >/dev/null 2>&1" >/dev/null 2>&1 &
  else
    ( sleep "$show_for"; rm -f "$show_file"; polybar-msg action "#${module_name}.hook.0" >/dev/null 2>&1 || true ) >/dev/null 2>&1 &
  fi
fi

if command -v notify-send >/dev/null 2>&1; then
  if notify-send "Battery" "${capacity}%" 2>/dev/null; then
    exit 0
  fi
fi

if command -v xmessage >/dev/null 2>&1; then
  xmessage -center "$message"
  exit 0
fi

if command -v zenity >/dev/null 2>&1; then
  zenity --info --text "$message" >/dev/null 2>&1
  exit 0
fi

printf '%s\n' "$message" > /tmp/polybar-battery.txt
