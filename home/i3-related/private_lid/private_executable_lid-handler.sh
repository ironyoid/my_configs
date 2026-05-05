#!/usr/bin/env bash

USER_NAME="ironyoid"
USER_HOME="/home/ironyoid"
USER_ID="$(id -u "$USER_NAME")"
DISPLAY=":0"
XAUTHORITY=""
XDG_RUNTIME_DIR="/run/user/${USER_ID}"

detect_xenv() {
  local pid env_line

  for pname in i3-with-shmlog i3; do
    pid="$(pgrep -u "$USER_NAME" -x "$pname" | head -n1)"
    if [ -n "$pid" ]; then
      while IFS= read -r env_line; do
        case "$env_line" in
          DISPLAY=*) DISPLAY="${env_line#DISPLAY=}" ;;
          XAUTHORITY=*) XAUTHORITY="${env_line#XAUTHORITY=}" ;;
          XDG_RUNTIME_DIR=*) XDG_RUNTIME_DIR="${env_line#XDG_RUNTIME_DIR=}" ;;
        esac
      done < <(tr '\0' '\n' < "/proc/${pid}/environ")
      break
    fi
  done

  if [ -z "$XAUTHORITY" ] || [ ! -r "$XAUTHORITY" ]; then
    if [ -r "${USER_HOME}/.Xauthority" ]; then
      XAUTHORITY="${USER_HOME}/.Xauthority"
    else
      XAUTHORITY="$(ls -t /tmp/xauth_* 2>/dev/null | head -n1)"
    fi
  fi
}

detect_xenv

run_user() {
  runuser -u "$USER_NAME" -- env \
    DISPLAY="$DISPLAY" \
    XAUTHORITY="$XAUTHORITY" \
    XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
    HOME="$USER_HOME" \
    "$@"
}

if grep -q closed /proc/acpi/button/lid/*/state; then
  run_user xrandr \
    --output DP-1-5 --auto \
    --output HDMI-1-0 --auto --primary --right-of DP-1-5 \
    --output eDP-2 --off
  run_user bash /home/ironyoid/.config/polybar/launch.sh
elif grep -q open /proc/acpi/button/lid/*/state; then
  run_user xrandr \
    --output eDP-2 --auto --primary \
    --output HDMI-1-0 --off \
    --output DP-1-5 --off
  run_user bash /home/ironyoid/.config/polybar/launch_edp.sh
fi
