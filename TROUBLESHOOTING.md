# Troubleshooting

## Windows — blank statusline and/or empty bash windows keep popping up

### Symptoms
- The statusline area is empty (no model / no bars).
- Several blank terminal windows appear, e.g.
  `/usr/bin/bash --login -i C:\Users\<you>\.claude\awesome-statusline.sh`,
  and a new one is added on every statusline refresh.

### Cause
Older installs used a Bash statusline on Windows. That could fail in two ways:
1. **Blank windows** — a bare `.sh` path could be launched through Windows file
   association / Git Bash interactive mode, so stdin/stdout never reached
   Claude Code.
2. **Blank content** — the Bash renderer needed `jq`; if `jq` was not on `PATH`,
   every JSON parse failed.

### Fix — automatic (recommended)
Re-run the installer. As of this version it:
- installs a native **`~/.claude/awesome-statusline.ps1`** renderer,
- sets `statusLine.command` to `powershell -NoProfile -ExecutionPolicy Bypass ...`,
- no longer requires Git Bash or `jq` on Windows.

```powershell
./install.ps1            # or ./install.ps1 l   (xs/s/m/l/xl)
```

Then restart Claude Code. Any blank windows already open can be closed — no new
ones will be created.

### Fix — manual
1. `~/.claude/settings.json` →
   ```json
   "statusLine": {
     "type": "command",
     "command": "powershell -NoProfile -ExecutionPolicy Bypass -File C:/Users/<you>/.claude/awesome-statusline.ps1 -Size large"
   }
   ```
2. Make sure `awesome-statusline.ps1` exists at that path. The installer copies
   it from `scripts/awesome-statusline-windows.ps1`.

---

## macOS / Linux — statusline characters wrap one-per-line inside tmux

### Symptoms
Inside a `tmux` session each glyph of the statusline is pushed onto its own line
(the bars and `38% / Usage / N/A` stack vertically). Outside tmux it renders fine.

### Cause
The statusline emits 24-bit **truecolor** escapes (`\033[38;2;r;g;bm`), **emoji**,
and **Unicode block glyphs** (`█`, `░`). When tmux is not configured for truecolor
(`RGB`/`Tc` capability missing), the display-width Claude Code computes for each
cell disagrees with what tmux actually draws, the cursor drifts, and cells wrap.

### Fix
Add truecolor support to `~/.tmux.conf`, then reload tmux:

```tmux
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",xterm-256color:RGB"
```

```bash
tmux kill-server   # or: tmux source-file ~/.tmux.conf  (then restart the session)
```

If wrapping persists after enabling truecolor, the cause is emoji/wide-glyph
width rather than color — switch to a lighter mode (`compact` / `small`), which
uses fewer wide glyphs.
