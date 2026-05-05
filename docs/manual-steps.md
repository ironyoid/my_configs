# Manual steps on a fresh deploy

These are things `chezmoi apply` and `scripts/install-packages.sh` cannot do for you. Run once on the new machine after the bootstrap, in the order below.

## 1. SSH key

Generate a fresh key on the new box and add the public half to GitHub.

```bash
ssh-keygen -t ed25519 -C "pichuginna96@gmail.com"
cat ~/.ssh/id_ed25519.pub
# paste into https://github.com/settings/keys
ssh -T git@github.com   # should greet you by username
```

Then re-point chezmoi at the SSH remote (the bootstrap one-liner clones over HTTPS):

```bash
git -C ~/.local/share/chezmoi remote set-url origin git@github.com:ironyoid/my_configs.git
```

## 2. /etc/pacman.conf

Add these lines to `/etc/pacman.conf` if they aren't already there (they pin Python and prevent accidental removal of pacman/glibc):

```
IgnorePkg = python
HoldPkg     = pacman glibc
```

Also enable multilib if you want 32-bit support (uncomment the `[multilib]` block).

## 3. CPU microcode

Pick the matching package and refresh the bootloader:

```bash
# AMD CPUs (incl. GMKtec EVO-X2 Ryzen AI Max+ 395)
sudo pacman -S amd-ucode

# Intel CPUs (the laptop)
sudo pacman -S intel-ucode

# Refresh GRUB
sudo grub-mkconfig -o /boot/grub/grub.cfg
# Or systemd-boot:
sudo bootctl update
```

## 4. GPU driver

Pick based on `lspci | grep -i vga`:

```bash
# AMD (EVO-X2 integrated Radeon 8060S, or any modern AMD card)
sudo pacman -S mesa vulkan-radeon libva-mesa-driver xf86-video-amdgpu

# NVIDIA (laptop discrete, optional)
sudo pacman -S nvidia-open nvidia-utils nvidia-settings libva-nvidia-driver
# Then add NVIDIA modules to mkinitcpio:
#   MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
sudo mkinitcpio -P

# Intel (rare on a desktop, common on laptops as iGPU)
sudo pacman -S mesa vulkan-intel intel-media-driver
```

## 5. Keyboard layout

If you want the US/RU layout with `Win+Space` toggle (on by default on the laptop):

```bash
sudo localectl set-x11-keymap us,ru "" "" grp:win_space_toggle
# vconsole keymap is independent:
sudo sed -i 's/^KEYMAP=.*/KEYMAP=us/' /etc/vconsole.conf
```

If you only want US, skip and ensure `~/.config/chezmoi/chezmoi.toml` has `ru_layout = false`.

## 6. Lock screen cache

`betterlockscreen` needs to bake a wallpaper into its cache before `--lock` works:

```bash
betterlockscreen -u ~/Pictures/lockscreen.jpg
```

## 7. SDDM theme (optional)

The laptop uses the `where-is-my-sddm` theme. If you want it on the desktop:

```bash
# Clone the theme repo into /usr/share/sddm/themes/, then:
sudo sed -i 's/^Current=.*/Current=where-is-my-sddm-theme/' /etc/sddm.conf  # may need creating
```

## 8. Oh-My-Zsh

The `.zshrc` references oh-my-zsh; install it after `.zshrc` is in place:

```bash
sh -c "$(curl -fsLS https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
chsh -s /usr/bin/zsh
```

## 9. Wire up Claude Code memory (optional)

The repo carries persistent Claude Code memory in `docs/memory/`. To make Claude Code on this machine read from there:

```bash
mkdir -p ~/.claude/projects/-home-ironyoid
ln -sfn ~/.local/share/chezmoi/docs/memory ~/.claude/projects/-home-ironyoid/memory
```

See `docs/memory/README.md` for details.

## 10. Set chezmoi data correctly on each machine

`chezmoi init` prompts the first time. To re-prompt or change values later, edit `~/.config/chezmoi/chezmoi.toml` directly. Reference values:

| Variable    | Laptop      | EVO-X2 desktop |
|-------------|-------------|----------------|
| `chassis`   | `laptop`    | `desktop`      |
| `wm`        | `i3`        | `i3` (sway later) |
| `gpu`       | `nvidia`    | `amd`          |
| `microcode` | `intel`     | `amd`          |
| `ru_layout` | `true`      | `false`        |

Run `chezmoi diff` after editing to preview, then `chezmoi apply`.
