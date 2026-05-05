#!/usr/bin/env bash
# Install pacman + AUR packages from packages/*.txt, pruning machine-specific cruft.
# Run on a fresh deploy AFTER yay is bootstrapped.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

if ! command -v yay >/dev/null 2>&1; then
    echo "yay is not installed. Bootstrap it first:" >&2
    echo "  sudo pacman -S --needed base-devel git" >&2
    echo "  git clone https://aur.archlinux.org/yay.git /tmp/yay && (cd /tmp/yay && makepkg -si)" >&2
    exit 1
fi

# Read this machine's chassis/gpu from chezmoi data.
CHASSIS=$(chezmoi data | python -c 'import json,sys; print(json.load(sys.stdin)["chassis"])')
GPU=$(chezmoi data | python -c 'import json,sys; print(json.load(sys.stdin)["gpu"])')
echo "Installing for chassis=$CHASSIS gpu=$GPU"

# Always-prune list: laptop-specific GPU/microcode that doesn't apply to most other machines.
# This is intentionally aggressive — install the right ones via the GPU/microcode block below.
PRUNE='^(nvidia|nvidia-open|nvidia-prime|nvidia-settings|nvidia-utils|libva-nvidia-driver|intel-ucode|intel-media-driver|xf86-video-intel|vulkan-intel|vulkan-nouveau|xf86-video-nouveau|amd-ucode|libva-mesa-driver|vulkan-radeon|xf86-video-amdgpu)$'

grep -Ev "$PRUNE" packages/pacman-explicit.txt > /tmp/pkglist.txt
echo "Installing $(wc -l < /tmp/pkglist.txt) pacman packages..."
sudo pacman -S --needed - < /tmp/pkglist.txt

# GPU + microcode for this machine
case "$GPU" in
    amd)
        sudo pacman -S --needed amd-ucode mesa vulkan-radeon libva-mesa-driver xf86-video-amdgpu
        ;;
    nvidia)
        sudo pacman -S --needed intel-ucode mesa nvidia-open nvidia-utils nvidia-settings libva-nvidia-driver
        echo "NVIDIA: remember to add nvidia,nvidia_modeset,nvidia_uvm,nvidia_drm to /etc/mkinitcpio.conf MODULES and rebuild."
        ;;
    intel)
        sudo pacman -S --needed intel-ucode mesa vulkan-intel intel-media-driver
        ;;
    *)
        echo "Unknown GPU '$GPU' — install drivers manually." >&2
        ;;
esac

echo "Installing $(wc -l < packages/aur-explicit.txt) AUR packages..."
yay -S --needed - < packages/aur-explicit.txt
