# my_configs

Arch Linux dotfiles, package lists, and deploy automation, managed with [chezmoi](https://www.chezmoi.io/).

## Layout

- `home/` — chezmoi source dir. User-level configs (i3, polybar, picom, rofi, wezterm, VS Code, zsh, fonts, etc). Per-machine deltas via templates + `.chezmoiignore`.
- `packages/` — `pacman -Qqen`, `pacman -Qqem`, enabled systemd units. Re-capture with `scripts/capture-packages.sh`.
- `scripts/` — install/enable/capture helpers (run after the chezmoi bootstrap).
- `docs/` — manual-steps and verification for first-time deploys.

The `legacy/aug-2025` branch holds the pre-chezmoi state of this repo (raw config copies + AR0233 kernel patches), preserved for reference.

## Bootstrap on a new machine

Fresh Arch base, user with sudo, network up, `git`+`curl`+`base-devel` installed.

```bash
# 1. chezmoi: clone repo, prompt for chassis/wm/gpu/microcode/ru_layout, apply.
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply ironyoid/my_configs

# 2. yay (AUR helper, one-time)
git clone https://aur.archlinux.org/yay.git /tmp/yay && (cd /tmp/yay && makepkg -si)

# 3. Packages (pacman + AUR, GPU + microcode based on chezmoi data)
~/.local/share/chezmoi/scripts/install-packages.sh

# 4. Services
~/.local/share/chezmoi/scripts/enable-services.sh

# 5. Manual steps (SSH key, pacman.conf tweaks, lock-screen cache, etc.)
$EDITOR ~/.local/share/chezmoi/docs/manual-steps.md

# 6. Verify
$EDITOR ~/.local/share/chezmoi/docs/verification.md
```

## Per-machine variables

Set on `chezmoi init` (prompts) or by editing `~/.config/chezmoi/chezmoi.toml`:

| Variable    | Laptop      | EVO-X2 desktop |
|-------------|-------------|----------------|
| `chassis`   | `laptop`    | `desktop`      |
| `wm`        | `i3`        | `i3` (sway later) |
| `gpu`       | `nvidia`    | `amd`          |
| `microcode` | `intel`     | `amd`          |
| `ru_layout` | `true`      | `false`        |

## Ongoing sync

```bash
# After editing live configs locally:
chezmoi re-add && chezmoi diff
chezmoi cd && git add -A && git commit -m "sync" && git push

# To pull updates on the other machine:
chezmoi update    # = git pull + chezmoi apply
```

A useful shell alias (already in `.zshrc` if you want it):

```bash
alias dotsync='chezmoi re-add && chezmoi diff && (chezmoi cd && git add -A && git commit -m "sync: $(date +%F)" && git push)'
alias dotpull='chezmoi update'
```
