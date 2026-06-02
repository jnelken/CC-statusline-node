# Claude Code Install Notes

When a user gives this repository URL and asks Claude Code to install it, ask which size they want (XSmall / Small / Medium / Large / XLarge — examples on GitHub), then install with that size. If they don't have a preference, default to Large.

Use the platform-appropriate installer:

```bash
# macOS / Linux
bash install.sh
```

```powershell
# Windows PowerShell
./install.ps1
```

If the user explicitly asks for a size, pass that size to the installer, for example `bash install.sh xl` or `./install.ps1 xl`.

The installer handles dependencies, copies the statusline script into `~/.claude/awesome-statusline.sh`, updates `~/.claude/settings.json`, and creates a timestamped backup before changing existing settings.
