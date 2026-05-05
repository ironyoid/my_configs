#!/usr/bin/env bash
set -euo pipefail

BAT="${1:-BAT0}"
module_name="${BATTERY_MODULE:-battery}"
hook_index="${BATTERY_HOOK:-0}"
LOW_THRESHOLD="${LOW_THRESHOLD:-20}"
SHOW_FOR="${SHOW_FOR:-5}"
SHOW_FILE="${SHOW_FILE:-/tmp/polybar-battery-show-${BAT}}"

cap_file="/sys/class/power_supply/${BAT}/capacity"
watcher_cmd="/home/ironyoid/.config/polybar/battery_watch.sh"
watcher_pid_file="/tmp/polybar-battery-watch-${module_name}.pid"

if [[ ! -r "$cap_file" ]]; then
  exit 0
fi

if [[ -x "$watcher_cmd" ]]; then
  if [[ -f "$watcher_pid_file" ]] && kill -0 "$(cat "$watcher_pid_file")" 2>/dev/null; then
    :
  else
    rm -f "$watcher_pid_file" 2>/dev/null || true
    if command -v nohup >/dev/null 2>&1; then
      BATTERY_MODULE="$module_name" BATTERY_HOOK="$hook_index" nohup "$watcher_cmd" "$module_name" "$hook_index" >/dev/null 2>&1 &
    else
      BATTERY_MODULE="$module_name" BATTERY_HOOK="$hook_index" "$watcher_cmd" "$module_name" "$hook_index" >/dev/null 2>&1 &
    fi
  fi
fi

capacity="$(cat "$cap_file")"

if (( capacity < 20 )); then
  icon=""
elif (( capacity < 40 )); then
  icon=""
elif (( capacity < 60 )); then
  icon=""
elif (( capacity < 85 )); then
  icon=""
else
  icon=""
fi

color="#e6dc44"
if (( capacity < LOW_THRESHOLD )); then
  color="#e65b3b"
fi

show_percent=0
if [[ -f "$SHOW_FILE" ]]; then
  ts="$(cat "$SHOW_FILE" 2>/dev/null || echo 0)"
  now="$(date +%s)"
  if [[ "$ts" =~ ^[0-9]+$ ]] && (( now - ts <= SHOW_FOR )); then
    show_percent=1
  fi
fi

output="%{F${color}}${icon}%{F-}"
if (( show_percent == 1 )); then
  output="${output} ${capacity}%"
fi

printf '%s\n' "$output"
