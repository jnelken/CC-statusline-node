# Claude Code Install Notes

When asked to install this repo, ask the size first, then run the installer.
Keep it plain: post the menu below **verbatim** and wait for the reply. Just
show the menu — do not narrate install rules, version numbers, or release notes.

Do **not** use the AskUserQuestion tool here: it caps at 4 options, and this
menu has 5 (xsmall is dropped or shuffled every time it's forced into 4). Post
the menu as a normal message instead.

Post this menu exactly, then wait for a reply. **Default to the English block.**
Use the Korean block only when the user is actually writing to you in Korean.

English:

```
Which size would you like to install? (examples on GitHub: https://github.com/AwesomeJun/CC-statusline)

  1. xsmall (xs) — Smallest, essentials only. For narrow screens.
  2. small  (s) — Space-saving, key info only.
  3. medium (m) — Balance of detail and space.
  4. large  (l) — Default. Shows most info.
  5. xlarge (xl) — Largest, full detail (git ahead/behind, env).

Reply with a number or name [default: 4 / large].
```

Korean:

```
statusline을 어떤 사이즈로 설치할까요? (예시는 GitHub에서 확인: https://github.com/AwesomeJun/CC-statusline)

  1. xsmall (xs) — 가장 작게, 핵심만. 좁은 화면용.
  2. small  (s) — 공간 절약, 주요 정보만.
  3. medium (m) — 정보량과 공간의 균형.
  4. large  (l) — 기본값. 대부분 정보 표시.
  5. xlarge (xl) — 가장 크게, 모든 정보 (git ahead/behind, env).

번호나 이름으로 답해 주세요 [기본값: 4 / large].
```

The reply maps to: `1`/`xs` → xsmall, `2`/`s` → small, `3`/`m` → medium,
`4`/`l` → large, `5`/`xl` → xlarge. An empty reply means large.

Then install with that size:

- macOS / Linux: `bash install.sh <size>`
- Windows PowerShell: `./install.ps1 <size>`

Shortcuts:

- If the user already named a size (e.g. "install the XL one"), skip the menu
  and install that size directly.
- In a non-interactive session (`claude -p`, hooks, automation) where you can't
  wait for a reply, install `large` directly.

The installer copies the statusline script into `~/.claude/awesome-statusline.*`,
updates `~/.claude/settings.json`, and makes a timestamped backup before
changing existing settings.
