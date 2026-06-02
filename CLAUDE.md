# Claude Code Install Notes

When a user gives this repository URL and asks Claude Code to install it, you MUST ask which size they want **using the AskUserQuestion tool** (XSmall / Small / Medium / Large / XLarge — examples on GitHub) *before* running the installer. Do not assume a default and do not replace the question with a "defaulting to Large" message. "Just install it" / giving only the URL is **not** a size preference — still ask.

Only skip the question and fall back to Large when interaction is genuinely impossible — i.e. a non-interactive session such as `claude -p` (print mode), a hook, or other automation where the AskUserQuestion tool cannot be used. In that case install Large and say so explicitly.

Once you have the size, install with that size (e.g. `bash install.sh xl` or `./install.ps1 xl`).

Use the platform-appropriate installer:

```bash
# macOS / Linux
bash install.sh
```

```powershell
# Windows PowerShell
./install.ps1
```

If the user already named a size in their request (e.g. "install the XL one"), skip the question and pass that size straight to the installer, for example `bash install.sh xl` or `./install.ps1 xl`.

The installer handles dependencies, copies the statusline script into `~/.claude/awesome-statusline.sh`, updates `~/.claude/settings.json`, and creates a timestamped backup before changing existing settings.
