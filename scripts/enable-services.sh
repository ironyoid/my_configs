#!/usr/bin/env bash
# Enable system services from packages/services.txt, skipping units that don't exist.
# Filters out machine-specific units (NVIDIA suspend hooks, klnagent64, getty templates).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

# Skip:
#   - NVIDIA suspend/resume hooks (only relevant when nvidia driver is installed)
#   - klnagent64 (Kaspersky, work machine only)
#   - getty@.service (template; system-managed)
#   - sockets that systemd auto-activates (varlink, monitor, networkd-resolve-hook)
SKIP='^(nvidia-.*|klnagent64\.service|getty@\.service|systemd-networkd-resolve-hook\.socket|systemd-resolved-monitor\.socket|systemd-resolved-varlink\.socket|systemd-userdbd\.socket|systemd-networkd-varlink\.socket)$'

while IFS= read -r unit; do
    [[ -z "$unit" ]] && continue
    if [[ "$unit" =~ $SKIP ]]; then
        echo "skip:    $unit"
        continue
    fi
    if ! systemctl list-unit-files "$unit" --no-legend 2>/dev/null | grep -q .; then
        echo "missing: $unit (package not installed?)"
        continue
    fi
    echo "enable:  $unit"
    sudo systemctl enable "$unit"
done < packages/services.txt

echo
echo "Done. Reboot or 'sudo systemctl start <unit>' for any you want running now."
