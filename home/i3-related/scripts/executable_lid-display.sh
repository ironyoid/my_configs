#!/bin/sh
# Lid-aware xrandr layout for i3
set -u

get_i3_env() {
  I3PID="$(pgrep -n -u "$USER" i3 || true)"
  if [ -n "$I3PID" ] && [ -r "/proc/$I3PID/environ" ]; then
    tr '\0' '\n' < "/proc/$I3PID/environ"
  fi
}

ensure_x_env() {
  I3ENV="$(get_i3_env || true)"
  if [ -n "${I3ENV:-}" ]; then
    DISP="$(printf '%s\n' "$I3ENV" | sed -n 's/^DISPLAY=//p' | head -n1)"
    [ -n "$DISP" ] && export DISPLAY="$DISP"
    XA="$(printf '%s\n' "$I3ENV" | sed -n 's/^XAUTHORITY=//p' | head -n1)"
    [ -n "$XA" ] && export XAUTHORITY="$XA"
  fi

  if [ -z "${DISPLAY:-}" ]; then
    export DISPLAY=:0
  fi

  if [ -z "${XAUTHORITY:-}" ] || [ ! -r "${XAUTHORITY:-}" ]; then
    [ -r "$HOME/.Xauthority" ] && export XAUTHORITY="$HOME/.Xauthority"
  fi

  # Fallback: common SDDM authority file locations
  if [ -z "${XAUTHORITY:-}" ] || [ ! -r "${XAUTHORITY:-}" ]; then
    for f in "/run/user/$(id -u)"/sddm* "/run/user/$(id -u)"/xauth* /var/run/sddm/*; do
      [ -r "$f" ] && export XAUTHORITY="$f" && break
    done
  fi
}

wait_for_x() {
  ensure_x_env
  until xrandr --query >/dev/null 2>&1; do
    sleep 0.5
    ensure_x_env
  done
}

get_outputs() {
  DP="$(xrandr --query | awk '/^DP.* connected/ {print $1; exit}')"
  HDMI="$(xrandr --query | awk '/^HDMI.* connected/ {print $1; exit}')"
  EDP="$(xrandr --query | awk '/^eDP.* connected/ {print $1; exit}')"
}

edp_active() {
  ensure_x_env
  xrandr --query | awk '
    /^eDP.* connected/ {
      found=1
      if ($3 ~ /^[0-9]+x[0-9]+/) { active=1 }
    }
    END {
      if (!found) exit 2
      exit(active ? 0 : 1)
    }
  '
}

layout_docked() {
  # Lid CLOSED: use BOTH externals, disable internal
  ensure_x_env
  get_outputs

  # If both externals exist, extend HDMI to the right of DP (or vice versa)
  if [ -n "${DP:-}" ] && [ -n "${HDMI:-}" ]; then
    xrandr --output "$DP" --auto \
           --output "$HDMI" --auto --primary --right-of "$DP"
  elif [ -n "${DP:-}" ]; then
    xrandr --output "$DP" --primary --auto
  elif [ -n "${HDMI:-}" ]; then
    xrandr --output "$HDMI" --primary --auto
  else
    xrandr --auto
  fi

  # Turn off laptop panel if present
  [ -n "${EDP:-}" ] && xrandr --output "$EDP" --off || true
  /home/ironyoid/.config/polybar/launch.sh
}

layout_open() {
  # Lid OPEN: enable both externals extended + enable internal (placed below primary external)
  ensure_x_env
  get_outputs

  # First, ensure externals are extended (no mirroring)
  if [ -n "${DP:-}" ] && [ -n "${HDMI:-}" ]; then
    xrandr --output "$DP" --auto \
           --output "$HDMI" --auto --primary --right-of "$DP"
    PRIMARY="$HDMI"
  elif [ -n "${DP:-}" ]; then
    xrandr --output "$DP" --primary --auto
    PRIMARY="$DP"
  elif [ -n "${HDMI:-}" ]; then
    xrandr --output "$HDMI" --primary --auto
    PRIMARY="$HDMI"
  else
    xrandr --auto
    PRIMARY=""
  fi

  # Then enable internal (avoid mirroring by placing it explicitly)
  if [ -n "${EDP:-}" ]; then
    if [ -n "${PRIMARY:-}" ]; then
      xrandr --output "$EDP" --auto --below "$PRIMARY"
    else
      xrandr --output "$EDP" --primary --auto
    fi
  fi
  /home/ironyoid/.config/polybar/launch.sh
}

lid_state() {
  # Try to find a lid state file
  for f in /proc/acpi/button/lid/*/state /proc/acpi/button/lid/*/LID/state /proc/acpi/button/lid/LID/state; do
    [ -r "$f" ] && awk '{print $NF}' "$f" && return 0
  done
  echo "unknown"
}

# Initial apply (important if you login with lid already closed)
wait_for_x
case "$(lid_state)" in
  closed) layout_docked ;;
  open)   layout_open ;;
  *)      layout_docked ;;  # safe default: prefer externals if present
esac

prev="$(lid_state)"
while :; do
  cur="$(lid_state)"
  edp_active
  edp_rc=$?
  if [ "$cur" != "$prev" ]; then
    case "$cur" in
      closed) layout_docked ;;
      open)   layout_open ;;
    esac
  else
    case "$cur" in
      closed)
        [ "$edp_rc" -eq 0 ] && layout_docked
        ;;
      open)
        [ "$edp_rc" -eq 1 ] && layout_open
        ;;
    esac
  fi
  prev="$cur"
  sleep 1
done
