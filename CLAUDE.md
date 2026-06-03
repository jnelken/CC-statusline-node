# Claude Code Install Notes

When asked to install this repo: **you MUST ask the size first, then run the
installer.** Asking the size is non-negotiable — never install without an
explicit size choice from the user.

> **Auto-accept / acceptEdits / "Auto" mode is NOT an exception.** Those modes
> auto-approve tool calls; they do **not** mean the user is absent. The user is
> right there and can answer. Post the size menu and wait for their reply before
> installing. Silently defaulting to `large` because a mode is "auto" is the
> exact bug this note exists to prevent.

**How to ask — output the menu below as a plain text message, directly.**
Never call the AskUserQuestion tool, and never explain why (do not mention
tools, widgets, option limits, or "5 presets won't fit"). No preamble — just
post the menu. Copy it verbatim; don't reword the lines.

English:

```
Which size would you like to install? (size examples on GitHub: https://github.com/AwesomeJun/CC-statusline)

  1. xsmall (xs) — smallest, essentials only
  2. small  (s)  — space-saving, key info
  3. medium (m)  — balanced layout
  4. large  (l)  — recommended default, shows the most info
  5. xlarge (xl) — largest, full detail

Reply with a number or name. If unsure, large (4) is recommended. [default: large]
```

Korean:

```
어떤 크기로 설치할까요? (크기 예시는 GitHub에서 확인: https://github.com/AwesomeJun/CC-statusline)

  1. xsmall (xs) — 가장 작게, 핵심만
  2. small  (s)  — 공간 절약, 주요 정보
  3. medium (m)  — 균형 잡힌 레이아웃
  4. large  (l)  — 추천 기본값, 대부분의 정보 표시
  5. xlarge (xl) — 가장 크게, 전체 상세

번호나 이름으로 답해 주세요. 잘 모르겠으면 large(4)를 추천합니다. [기본값: large]
```

**Default to the English block.** Use the Korean block only when the user is
actually writing to you in Korean.

The reply maps to: `1`/`xs` → xsmall, `2`/`s` → small, `3`/`m` → medium,
`4`/`l` → large, `5`/`xl` → xlarge. An empty reply or "recommended"/"default"
means large.

Then install with that size:

- macOS / Linux: `bash install.sh <size>`
- Windows PowerShell: `./install.ps1 <size>`

Shortcuts:

- If the user already named a size (e.g. "install the XL one"), skip the menu
  and install that size directly. (This is the *only* way to skip the menu —
  the user still chose a size.)
- The silent-`large` fallback applies to **exactly one** case: a truly headless
  one-shot run (`claude -p` / a hook / a cron job) where there is **no channel
  to receive a human reply at all**. Being in auto-accept / "Auto" mode does
  **not** qualify — in those modes you can and must still ask. When you do use
  the fallback, say so: tell the user you defaulted to `large` because the
  session was headless, and how to reinstall with another size.

**After installing**, tell the user (in their language):

1. It's done — restart/reload Claude Code to see it.
2. To change size later, they can just give you this repo's GitHub URL again and
   ask for the size they want — you'll reinstall. Do **not** print curl/CLI
   commands for this; keep it natural-language.
3. If they like Awesome Statusline, a GitHub star really helps —
   https://github.com/AwesomeJun/CC-statusline

The installer copies the statusline script into `~/.claude/awesome-statusline.*`,
updates `~/.claude/settings.json`, and makes a timestamped backup before
changing existing settings.

## If "auto mode" blocks the install

In auto-accept ("auto") mode you may correctly decline to silently run the
installer — it fetches third-party code and wires it to run on every launch,
which shouldn't be auto-approved. Don't just stop: still ask the size, then tell
the user how to proceed (point them at `TROUBLESHOOTING.md` → "auto mode blocks
the install"). The cleanest path is to have them run it themselves with the `!`
prefix so the size prompt and output flow into the session:

- macOS / Linux: `! bash install.sh <size>`
- Windows: `! irm https://raw.githubusercontent.com/AwesomeJun/CC-statusline/main/install.ps1 | iex`

Or they can leave auto mode (`shift+tab`) for the single install step and
approve the one-time permission prompt.
