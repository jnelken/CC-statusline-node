---
description: Install or switch the Awesome Statusline preset (xs-xl)
argument-hint: "[xsmall|small|medium|large|xlarge]"
---

Install (or switch) the Awesome Statusline for the user.

## Pick the size first — MANDATORY

You **MUST** resolve the size before running the installer. Never install
without an explicit size.

- If the user gave a size in `$ARGUMENTS` (abbreviation `xs`/`s`/`m`/`l`/`xl` or
  full name), use it and skip the menu.
- Otherwise, **ask the size using the exact method in this repo's `CLAUDE.md`**
  ("Claude Code Install Notes" → the plain-text size menu). `CLAUDE.md` is the
  single source of truth for *how* to ask — do not invent a different mechanism
  here, so the two never drift apart.
- Auto-accept / "Auto" mode is **not** a reason to skip the menu. Only a truly
  headless run (`claude -p`, hook, cron — no way to receive a reply) may fall
  back to `large`, and you must tell the user it defaulted.

Pass the resolved size explicitly to the installer (this also avoids relying on
the installer's own interactive prompt, which pipe-based installs can suppress).

## Run the installer

Run the bundled installer for the user's platform with the resolved size.
Replace `<size>` with the size from `$ARGUMENTS` or the user's answer
(`xsmall`/`small`/`medium`/`large`/`xlarge`, or the `xs`/`s`/`m`/`l`/`xl`
abbreviation):

```bash
# macOS / Linux
bash "${CLAUDE_PLUGIN_ROOT}/install.sh" <size>
```

```powershell
# Windows PowerShell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:CLAUDE_PLUGIN_ROOT\install.ps1" <size>
```

The installer will:
- auto-install `jq` on macOS/Linux if needed,
- use a native PowerShell renderer on Windows, with no Git Bash or `jq` required,
- copy the chosen renderer to `~/.claude/awesome-statusline.*`,
- set `statusLine` in `~/.claude/settings.json` (backing up the previous file first).

After it finishes, confirm the `statusLine` entry was written and tell the user
to restart Claude Code to see the new statusline. The five sizes, smallest to
largest, are: `xsmall` (2 lines) · `small` (2 lines) · `medium` (4 lines) ·
`large` (5 lines) · `xlarge` (5 lines, full detail).
