#!/usr/bin/env bash
set -euo pipefail

module_name="${1:-${BATTERY_MODULE:-battery}}"
hook_index="${2:-${BATTERY_HOOK:-0}}"
poll_interval="${POLL_INTERVAL:-5}"
pid_file="/tmp/polybar-battery-watch-${module_name}.pid"

if [[ -f "$pid_file" ]] && kill -0 "$(cat "$pid_file")" 2>/dev/null; then
  exit 0
fi

echo "$$" > "$pid_file"

udev_pid=""
cleanup() {
  if [[ -n "$udev_pid" ]]; then
    kill "$udev_pid" 2>/dev/null || true
  fi
  rm -f "$pid_file"
}
trap cleanup EXIT

send_update() {
  if command -v polybar-msg >/dev/null 2>&1; then
    polybar-msg action "#${module_name}.hook.${hook_index}" >/dev/null 2>&1 || true
  fi
}

send_update

if command -v udevadm >/dev/null 2>&1; then
  udevadm monitor --udev --subsystem-match=power_supply --property | while IFS= read -r line; do
    if [[ -z "$line" ]]; then
      send_update
    fi
  done &
  udev_pid=$!
fi

while sleep "$poll_interval"; do
  send_update
done
