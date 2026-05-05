# Post-deploy verification

Run on the new machine after the bootstrap + manual steps. Each item is independent — fix any that fail before moving on.

## Session

- `loginctl` — shows your user with an SDDM-launched seat0 session.
- `echo $XDG_SESSION_TYPE` — `x11` (or `wayland` once you switch to sway).
- `systemctl --failed` — empty.

## i3 + bar + compositor

- `Super+Return` — opens wezterm with Batman colors and Iosevka/JBM glyphs (no tofu where icons should be).
- `pgrep polybar` — returns ≥1 PID; bar appears at the top of every monitor.
- Polybar modules visible: workspaces, audio, network, VPN, clock. **No `[battery]` module on the desktop** (gated by `.laptop`).
- `pgrep picom` — returns a PID; transparency between focused/unfocused windows is visibly different.
- `rofi -show drun` — opens with the squared-batman theme.
- `betterlockscreen -l` — locks the screen; password unlocks; cache populated.

## Editor + shell

- `code` — opens with BatmanDark theme. A custom binding from `keybindings.json` works.
- `echo $SHELL` — `/usr/bin/zsh`. Prompt uses oh-my-zsh's robbyrussell theme.
- `git config user.email` — `pichuginna96@gmail.com`.

## Keyboard, audio, fonts

- `setxkbmap -query` — matches your `ru_layout` choice. With `ru_layout=true`, `Win+Space` toggles US/RU.
- `pulseaudio --check -v` — returns running. `pavucontrol` shows the right output device.
- `fc-list | grep -iE "iosevka|jetbrains|icomoon|grapenuts"` — all four custom fonts present.

## Chezmoi consistency

- `chezmoi diff` — empty. Deploy matches the repo.
- `~/.config/chezmoi/chezmoi.toml` — values match the table in `manual-steps.md` for this machine.

## Per-machine excludes (sanity check)

On the **desktop** (chassis=desktop):
- `~/i3-related/scripts/lid-display.sh` does NOT exist (correctly excluded).
- `~/.config/polybar/battery_*.sh` do NOT exist.

On the **laptop** (chassis=laptop):
- All of the above DO exist.
