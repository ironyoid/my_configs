---
name: Collaboration preferences
description: How Nikita wants Claude to operate during sessions — sudo, destructive ops, output style
type: feedback
---

Nikita runs sudo commands himself — don't invoke sudo via the Bash tool.

**Why:** Stated explicitly during the dotfiles work on 2026-05-05 ("Let me do sudo commands"). Sudo via the agent requires a non-interactive password path and adds friction.

**How to apply:** When a step needs sudo, describe what to run, hand it to him, and continue when he confirms. This applies to package installs, /etc edits, systemctl, mkinitcpio, etc.

---

When destructively rewriting git history (force-push, branch reset, orphan main), preserve the prior state on a named branch first.

**Why:** During the my_configs reset on 2026-05-05 he picked "preserve old as legacy/aug-2025" over "wipe history" specifically to keep the AR0233 kernel patches reachable in case they're needed again later.

**How to apply:** Default to additive-then-destructive ordering — push the legacy branch and verify it's on the remote before force-pushing the target branch.

---

Prefer terse, decision-focused output over verbose summaries; push back when scope creeps.

**Why:** During the dotfiles plan he trimmed proposed scope twice (cut /etc tracking, cut AR0233 preservation in main, deferred sway). Validates concise revisions; pushes back on additions.

**How to apply:** Skip end-of-turn recaps unless they add information. State decisions and next steps directly. When proposing scope, lean smaller and let him expand if he wants more.
