# Persistent Claude Code memory, repo-resident

These files are the auto-memory format Claude Code's harness reads (frontmatter + content + a `MEMORY.md` index). Storing them in the repo means they sync to every machine that clones `my_configs`, so context survives across hosts and reinstalls.

## Wiring up auto-memory to read from here

Claude Code looks for memory at `~/.claude/projects/-home-ironyoid/memory/` (path is derived from the user's home dir). To make that location point at this folder, after `chezmoi init` clones the repo:

```bash
mkdir -p ~/.claude/projects/-home-ironyoid
ln -sfn ~/.local/share/chezmoi/docs/memory ~/.claude/projects/-home-ironyoid/memory
```

After that, any future Claude Code session in `~/` (or anywhere under `/home/ironyoid` matching that scope) will load `MEMORY.md` and follow its links.

## Editing

Edit the files here, commit, push. On the other machine, `cd ~/.local/share/chezmoi && git pull` — the symlink means the new content is live immediately.

If Claude Code in a future session asks to save a memory, it will write into `~/.claude/projects/.../memory/`, which (via the symlink) lands in this directory. Stage and commit.
