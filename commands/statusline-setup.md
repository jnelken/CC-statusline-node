---
description: Install or switch the Awesome Statusline preset (xs-xl)
argument-hint: "[xsmall|small|medium|large|xlarge]"
---

Install (or switch) the Awesome Statusline for the user.

Run the bundled installer with the requested size. If the user gave a size in
`$ARGUMENTS` (abbreviation `xs`/`s`/`m`/`l`/`xl` or full name), pass it through;
otherwise run the installer without arguments:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/install.sh" $ARGUMENTS
```

The installer will:
- auto-install `jq` (and Git Bash on Windows) via the system package manager,
- copy the chosen preset to `~/.claude/awesome-statusline.sh`,
- set `statusLine` in `~/.claude/settings.json` (backing up the previous file first).

After it finishes, confirm the `statusLine` entry was written and tell the user
to restart Claude Code to see the new statusline. The five sizes, smallest to
largest, are: `xsmall` (2 lines) · `small` (2 lines) · `medium` (4 lines) ·
`large` (5 lines) · `xlarge` (5 lines, full detail).
