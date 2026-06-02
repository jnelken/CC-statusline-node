#!/usr/bin/env bash
# ============================================================================
# Awesome CC Statusline — installer (macOS / Linux / Windows-GitBash)
# ----------------------------------------------------------------------------
# Usage:
#   ./install.sh                 # install
#   ./install.sh l               # install by abbreviation
#   ./install.sh large           # install by full name
#
# Sizes (smallest -> largest):
#   xsmall (xs)   2 lines, 10-block bars, minimal
#   small  (s)    2 lines, 10-block bars, labels + %
#   medium (m)    4 lines, classic layout
#   large  (l)    5 lines, 20-block bars, cost/time
#   xlarge (xl)   5 lines, 40-block bars, full detail (git ahead/behind, env)
#
# What it does:
#   1. ensures `jq` is installed (auto-installs via the system package manager)
#   2. copies the chosen size script to ~/.claude/awesome-statusline.sh
#   3. sets settings.json -> statusLine.command (existing settings preserved,
#      a timestamped backup is made first)
#
# Honors $CLAUDE_CONFIG_DIR (defaults to ~/.claude) so it is safe to test.
# ============================================================================
set -euo pipefail

# --- paths ------------------------------------------------------------------
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
SETTINGS="$CLAUDE_DIR/settings.json"
DEST="$CLAUDE_DIR/awesome-statusline.sh"
# Resolve script dir safely. Under `curl ... | bash` the script arrives on
# stdin, so BASH_SOURCE is unset — with `set -u` that would crash here. Fall
# back to an empty SCRIPT_DIR, which routes us to the repo-download branch.
if [ -n "${BASH_SOURCE:-}" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  SCRIPT_DIR=""
fi
SRC_DIR="$SCRIPT_DIR/scripts"
REPO_RAW="${AWESOME_STATUSLINE_RAW:-https://raw.githubusercontent.com/AwesomeJun/CC-statusline/main}"

# --- output helpers ---------------------------------------------------------
err()  { printf '\033[31m%s\033[0m\n' "$*" >&2; }
ok()   { printf '\033[32m%s\033[0m\n' "$*"; }
info() { printf '\033[36m%s\033[0m\n' "$*"; }

# map abbreviation OR full name -> canonical full name
normalize_mode() {
  case "$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')" in
    xs|xsmall)  echo "xsmall" ;;
    s|small)    echo "small"  ;;
    m|medium)   echo "medium" ;;
    l|large)    echo "large"  ;;
    xl|xlarge)  echo "xlarge" ;;
    *) return 1 ;;
  esac
}

# --- dependency: jq (auto-install) ------------------------------------------
install_jq() {
  info "jq not found — attempting automatic install…"
  if   command -v brew    >/dev/null 2>&1; then brew install jq
  elif command -v apt-get >/dev/null 2>&1; then sudo apt-get update && sudo apt-get install -y jq
  elif command -v dnf     >/dev/null 2>&1; then sudo dnf install -y jq
  elif command -v yum     >/dev/null 2>&1; then sudo yum install -y jq
  elif command -v pacman  >/dev/null 2>&1; then sudo pacman -S --noconfirm jq
  elif command -v zypper  >/dev/null 2>&1; then sudo zypper install -y jq
  elif command -v apk     >/dev/null 2>&1; then sudo apk add jq
  elif command -v winget  >/dev/null 2>&1; then winget install --silent --accept-package-agreements --accept-source-agreements jqlang.jq
  elif command -v scoop   >/dev/null 2>&1; then scoop install jq
  elif command -v choco   >/dev/null 2>&1; then choco install jq -y
  else
    err "No supported package manager found. Please install jq manually:"
    err "  https://jqlang.github.io/jq/download/"
    return 1
  fi
}

ensure_jq() {
  if ! command -v jq >/dev/null 2>&1; then
    install_jq || exit 1
    command -v jq >/dev/null 2>&1 || { err "jq install did not succeed."; exit 1; }
    ok "jq installed."
  fi
}

# --- pick size --------------------------------------------------------------
# Precedence: explicit argument > interactive prompt > 'large' default.
MODE="large"

# Korean locale? Show the prompt in Korean; otherwise default to English.
is_korean_locale() {
  case "${LC_ALL:-${LC_MESSAGES:-${LANG:-}}}" in
    ko|ko_*|ko.*|ko-*) return 0 ;;
    *) return 1 ;;
  esac
}

# Ask the user which preset to install (default large). Reads from the given fd.
prompt_size() {
  echo
  if is_korean_locale; then
    echo "statusline을 어떤 사이즈로 설치할까요? (XSmall-Small-Medium-Large-XLarge, 예시는 github에서 확인)"
    echo "  예시: https://github.com/AwesomeJun/CC-statusline"
    echo
    echo "  1. xsmall (xs)"
    echo "     가장 작게 — 핵심 정보만 최소 표시. 좁은 화면용."
    echo "  2. small (s)"
    echo "     작게 — 공간 절약, 주요 정보만."
    echo "  3. medium (m)"
    echo "     중간 — 정보량과 공간의 균형."
    echo "  4. large (l)"
    echo "     크게 — 현재 기본값. 대부분 정보 표시."
    echo "  5. xlarge (xl)"
    echo "     가장 크게 — 모든 정보 표시 (git ahead/behind, env)."
    echo
    printf '선택 [기본값: 4]: '
  else
    echo "Which size would you like to install? (XSmall-Small-Medium-Large-XLarge; see examples on GitHub)"
    echo "  Examples: https://github.com/AwesomeJun/CC-statusline"
    echo
    echo "  1. xsmall (xs)"
    echo "     Smallest — only the essentials. For narrow screens."
    echo "  2. small (s)"
    echo "     Small — space-saving, key info only."
    echo "  3. medium (m)"
    echo "     Medium — balance of detail and space."
    echo "  4. large (l)"
    echo "     Large — current default. Shows most info."
    echo "  5. xlarge (xl)"
    echo "     Largest — full detail (git ahead/behind, env)."
    echo
    printf 'Choice [default: 4]: '
  fi
  local answer=""
  read -r answer || answer=""
  case "$answer" in
    1)     MODE="xsmall" ;;
    2)     MODE="small"  ;;
    3)     MODE="medium" ;;
    4|"")  MODE="large"  ;;
    5)     MODE="xlarge" ;;
    *)
      # Allow typing a size name/alias directly instead of a number.
      if ! MODE="$(normalize_mode "$answer")"; then
        if is_korean_locale; then
          echo "알 수 없는 입력 '$answer' — 'large'로 설치합니다."
        else
          echo "Unknown input '$answer', using 'large'."
        fi
        MODE="large"
      fi
      ;;
  esac
}

if [ "$#" -ge 1 ]; then
  if ! MODE="$(normalize_mode "$1")"; then
    err "Unknown size: '$1'"
    err "Valid: xsmall|xs  small|s  medium|m  large|l  xlarge|xl"
    exit 1
  fi
elif [ -t 0 ]; then
  # Normal `./install.sh` / `bash install.sh` — stdin is the terminal.
  prompt_size
elif { exec 3</dev/tty; } 2>/dev/null; then
  # Piped install (`curl ... | bash`): the script body is on stdin, but a
  # controlling terminal still exists — prompt through /dev/tty.
  prompt_size <&3
  exec 3<&-
fi
# Truly non-interactive (CI, Claude Code, redirected stdin with no tty): neither
# branch runs, so MODE stays 'large' and the install never blocks.

# --- run --------------------------------------------------------------------
ensure_jq
mkdir -p "$CLAUDE_DIR"

SRC="$SRC_DIR/awesome-statusline-$MODE.sh"
if [ -f "$SRC" ]; then
  cp "$SRC" "$DEST"
else
  info "Local scripts/ not found, downloading size '$MODE' from repo…"
  curl -fsSL "$REPO_RAW/scripts/awesome-statusline-$MODE.sh" -o "$DEST" \
    || { err "Download failed. Check network or \$AWESOME_STATUSLINE_RAW."; exit 1; }
fi
chmod +x "$DEST"

# Invoke via `bash <script>` (not the bare path) so the statusline runs
# identically on every platform. On Windows a bare `.sh` path is opened through
# its file association (`bash --login -i ...`), which spawns visible terminal
# windows and breaks stdin/stdout — calling bash explicitly avoids that.
STATUSLINE_JSON='{"type":"command","command":"bash ~/.claude/awesome-statusline.sh"}'
if [ -f "$SETTINGS" ]; then
  BACKUP="$SETTINGS.backup-$(date +%Y%m%d-%H%M%S)"
  cp "$SETTINGS" "$BACKUP"
  jq --argjson sl "$STATUSLINE_JSON" '.statusLine = $sl' "$SETTINGS" > "$SETTINGS.tmp" \
    && mv "$SETTINGS.tmp" "$SETTINGS"
  info "Existing settings backed up to: $BACKUP"
else
  jq -n --argjson sl "$STATUSLINE_JSON" '{statusLine: $sl}' > "$SETTINGS"
fi

ok "Installed Awesome CC Statusline (size: $MODE)"
echo "  script:   $DEST"
echo "  settings: $SETTINGS  (statusLine set)"
echo
echo "Restart Claude Code (or reload) to see it."
echo "To switch size later, just ask your AI agent to reinstall at the size you want."
echo
echo "⭐ If you like Awesome Statusline, a GitHub star really helps:"
echo "   https://github.com/AwesomeJun/CC-statusline"
