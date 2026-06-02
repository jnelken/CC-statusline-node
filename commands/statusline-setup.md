---
description: Install or switch the Awesome Statusline preset (xs-xl)
argument-hint: "[xsmall|small|medium|large|xlarge]"
---

Install (or switch) the Awesome Statusline for the user.

## Pick the size first

There are **five** size presets, smallest to largest: `xsmall` · `small` ·
`medium` · `large` · `xlarge`.

- If the user gave a size in `$ARGUMENTS` (abbreviation `xs`/`s`/`m`/`l`/`xl` or
  full name), skip the question and pass it straight through to the installer.
- Otherwise, ask with **AskUserQuestion**. The tool allows at most 4 options, so
  show the four smallest as options and route `xlarge` + customization through
  the auto-provided **Other** choice:
  - **Question text:** use the same wording as the installer (install.sh) prompt,
    matching the user's language:
    - Korean: "statusline을 어떤 사이즈로 설치할까요? (XSmall-Small-Medium-Large-XLarge, 예시는 github에서 확인)"
    - English: "Which size would you like to install? (XSmall-Small-Medium-Large-XLarge; see examples on GitHub)"
  - **Option 1 — `xsmall` (xs):** 2 lines, 10-block bars, minimal.
  - **Option 2 — `small` (s):** 2 lines, 10-block bars, labels + %.
  - **Option 3 — `medium` (m):** 4 lines, classic layout.
  - **Option 4 — `large` (l) (Recommended):** 5 lines, 20-block bars, cost/time. This is the installer default.
  - In the question text, tell the user that **`xlarge` (xl)** — 5 lines, 40-block
    bars, full detail (git ahead/behind, env) — and any **customization** are
    available by picking **Other** and typing the size (`xl`/`xlarge`) or request.
- Pass the chosen size explicitly to the installer (this also avoids relying on
  the installer's interactive prompt, which pipe-based installs can suppress).

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
