---
name: External systems referenced from configs
description: Pointers to non-public servers and services that appear in dotfiles or workflows
type: reference
---

- **SonarQube** (work, internal): `http://172.16.170.7:9000/` — configured in VS Code SonarLint settings. Requires VPN/network access to the work LAN.
- **Remote SSH targets** (work): `orin-ubuntu` and `orin-yocto` — Jetson Orin development boards. Hardcoded paths appear in VS Code Remote-SSH install location overrides; SSH connection details live in `~/.ssh/config` (not tracked in dotfiles).
- **Hiddify VPN**: config at `~/.local/share/app.hiddify.com/` (not tracked; reconfigure per machine).
