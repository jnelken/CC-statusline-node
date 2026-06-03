---
description: Install or switch the Awesome Statusline preset (xs-xl)
argument-hint: "[xsmall|small|medium|large|xlarge]"
---

Install (or switch) the Awesome Statusline for the user.

## Pick the size first — MANDATORY

You **MUST** resolve the size before running the installer. Never install
without an explicit size. This section is **self-contained** — do not rely on
the repo's `CLAUDE.md` being loaded (it is *not* loaded when this command runs
from the installed plugin inside another project).

> Keep the two menu blocks below byte-identical to the ones in this repo's
> `CLAUDE.md`. They are duplicated on purpose (different load contexts) — if you
> edit one, edit the other.

- If the user named a size in `$ARGUMENTS` (`xs`/`s`/`m`/`l`/`xl` or full name),
  use it and skip the menu.
- Otherwise, **post the menu below as a plain-text message, verbatim.** Do
  **NOT** call the AskUserQuestion tool — it caps at 4 options and silently
  drops `xlarge`. Do not reword, reorder, or explain; just post it. Default to
  the English block; use Korean only when the user writes to you in Korean.

English:

```
Which size would you like to install? (size examples on GitHub: https://github.com/AwesomeJun/CC-statusline)

  1. xsmall (xs) — smallest, essentials only
  2. small  (s)  — space-saving, key info
  3. medium (m)  — balanced layout
  4. large  (l)  — recommended default, shows the most info
  5. xlarge (xl) — largest, full detail (git ahead/behind, env)

Reply with a number or name. If unsure, large (4) is recommended. [default: large]
```

Korean:

```
어떤 크기로 설치할까요? (크기 예시는 GitHub에서 확인: https://github.com/AwesomeJun/CC-statusline)

  1. xsmall (xs) — 가장 작게, 핵심만
  2. small  (s)  — 공간 절약, 주요 정보
  3. medium (m)  — 균형 잡힌 레이아웃
  4. large  (l)  — 추천 기본값, 대부분의 정보 표시
  5. xlarge (xl) — 가장 크게, 전체 상세 (git ahead/behind, env)

번호나 이름으로 답해 주세요. 잘 모르겠으면 large(4)를 추천합니다. [기본값: large]
```

Reply maps: `1`/`xs` → xsmall, `2`/`s` → small, `3`/`m` → medium, `4`/`l` →
large, `5`/`xl` → xlarge. Empty / "recommended" / "default" → large.

Auto-accept / "Auto" mode is **not** a reason to skip the menu — the user is
present and can answer. Only a truly headless run (`claude -p`, hook, cron — no
way to receive a reply) may fall back to `large`, and you must say you did.

Pass the resolved size explicitly to the installer.

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
