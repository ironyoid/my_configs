---
name: my_configs dotfiles strategy
description: Strategy and key decisions for the github.com/ironyoid/my_configs dotfiles repo
type: project
---

The dotfiles repo at `github.com/ironyoid/my_configs` was rebuilt on 2026-05-05 around chezmoi. Source dir is `home/` (per `.chezmoiroot`). Per-machine variables (`chassis`, `wm`, `gpu`, `microcode`, `ru_layout`) are prompted at `chezmoi init` and stored in `~/.config/chezmoi/chezmoi.toml`. Mutually-exclusive `.chezmoiignore` blocks gate i3 vs sway trees by `.wm`. Laptop-only files (lid handler, polybar battery scripts) gated by `.chassis`.

**Why:** The pre-2026 ad-hoc "manually cp the file when I remember" approach left the repo 8 months stale by the time Nikita wanted to deploy a new machine. Chezmoi's templating handles laptop↔desktop hardware deltas in-file rather than requiring per-host branches — that was the explicit pain point.

**How to apply:** Treat the chezmoi layout as the system of record for both machines. The `legacy/aug-2025` branch holds the pre-chezmoi state and the AR0233 kernel patches — reference but don't restore into main. /etc is intentionally not tracked (handled by `docs/manual-steps.md` as a checklist). Keep this memory living in `docs/memory/` so it travels with the repo.

---

Sway-on-desktop is a planned future migration, deliberately out of scope for the initial chezmoi capture.

**Why:** Decided 2026-05-05 to keep both machines on i3 first ("when I will be ready to shift to sway we do it"). The `wm` variable and sway-tree `.chezmoiignore` block are wired up so the future flip is a config edit, not a restructure.

**How to apply:** Don't propose sway changes proactively. When the topic comes up, the design is ready — translation table: polybar→waybar, picom→sway built-in compositor, rofi-X11→rofi-wayland or fuzzel, betterlockscreen→swaylock(+effects), xss-lock→swayidle, xsetroot/feh→swaybg, xrandr→sway `output` blocks, xclip→wl-clipboard, maim→grim+slurp, dunst→mako.
