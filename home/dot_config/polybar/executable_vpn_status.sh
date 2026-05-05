#!/usr/bin/env bash
set -euo pipefail

VPN_DIR="${VPN_DIR:-$HOME/vpn}"
format="name-status"
configs=()

usage() {
  cat <<'EOF'
Usage: vpn_status.sh [options] [config...]
Options:
  --format <name-status|status|name>
  --status-only
  --name-only
  -h, --help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --format)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --format" >&2
        exit 1
      fi
      format="$2"
      shift 2
      ;;
    --status-only)
      format="status"
      shift
      ;;
    --name-only)
      format="name"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      configs+=("$@")
      break
      ;;
    *)
      configs+=("$1")
      shift
      ;;
  esac
done

if [[ ${#configs[@]} -eq 0 ]]; then
  configs=(
    "$VPN_DIR/napichugin-internal.ovpn"
    "$VPN_DIR/vless-config.json"
  )
fi

status_for_config() {
  local config="$1"
  local format="$2"
  local display_name
  local resolved_config
  local config_ext
  local ifname
  local pid_file
  local status

  if [[ "$config" == */* ]]; then
    display_name="$(basename "$config")"
  else
    display_name="$config"
  fi

  resolved_config="$config"
  if [[ "$config" != */* && -f "$VPN_DIR/$config" ]]; then
    resolved_config="$VPN_DIR/$config"
  fi

  display_name="${display_name%.*}"
  config_ext="${resolved_config##*.}"

  if [[ "$config_ext" == "json" ]]; then
    if ip link show tun-vless >/dev/null 2>&1; then
      status="up"
    else
      status="down"
    fi
  elif [[ "$config_ext" == "conf" ]]; then
    ifname="$display_name"
    if ip link show "$ifname" >/dev/null 2>&1; then
      status="up"
    else
      status="down"
    fi
  else
    pid_file="/tmp/openvpn-$(basename "$resolved_config").pid"
    if [[ -f "$pid_file" ]] && [[ -d "/proc/$(cat "$pid_file")" ]]; then
      status="up"
    else
      status="down"
    fi
  fi

  case "$format" in
    status)
      printf "%s" "$status"
      ;;
    name)
      printf "%s" "$display_name"
      ;;
    name-status|*)
      printf "%s:%s" "$display_name" "$status"
      ;;
  esac
}

out=()
for cfg in "${configs[@]}"; do
  out+=("$(status_for_config "$cfg" "$format")")
done

printf "%s\n" "${out[*]}"
