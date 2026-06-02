# 트러블슈팅 — `curl | bash` 파이프 설치 시 `BASH_SOURCE[0]: unbound variable`

**작성일:** 2026-06-02
**대상:** `install.sh` (Awesome CC Statusline installer)
**증상 발생 환경:** macOS (zsh/bash), README 권장 설치 명령 사용 시

---

## 1. 증상

README가 권장하는 원라인 설치 명령을 그대로 실행하면 즉시 실패한다.

```bash
curl -fsSL https://raw.githubusercontent.com/AwesomeJun/CC-statusline/main/install.sh | bash -s -- xs
```

```
bash: line 31: BASH_SOURCE[0]: unbound variable
bash: line 31: cd: null directory
```

설치가 전혀 진행되지 않고 종료된다 (스크립트 31번째 줄에서 죽음).

---

## 2. 근본 원인

문제는 `install.sh`의 **두 가지 설계가 충돌**하기 때문이다.

### (a) `set -u` — unbound 변수 금지 (25번 줄)

```bash
set -euo pipefail
```

`-u` 옵션은 **정의되지 않은 변수를 참조하면 즉시 에러**로 죽게 만든다. 안전성을 위한 좋은 관행이지만, 아래 (b)와 결합하면 함정이 된다.

### (b) `BASH_SOURCE[0]`로 자기 자신의 경로 계산 (31번 줄)

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/scripts"
```

`BASH_SOURCE[0]`은 "지금 실행 중인 스크립트 파일의 경로"를 담는 bash 내장 배열이다. 스크립트를 **파일로 실행**할 때만 값이 채워진다.

- `bash install.sh` → `BASH_SOURCE[0]` = `install.sh` ✅ (파일 경로 존재)
- `curl ... | bash` → 스크립트 본문이 **stdin(표준 입력)으로 흘러 들어옴**. 실행 중인 "파일"이 없으므로 `BASH_SOURCE[0]`은 **설정되지 않음(unset)** ❌

### 충돌의 결과

파이프 실행에서는 `BASH_SOURCE[0]`이 unset인데, `set -u`가 켜져 있으므로 그 참조 자체가 에러가 된다. 그래서 31번 줄에서:

1. `${BASH_SOURCE[0]}` 참조 → **unbound variable 에러**
2. (만약 `-u`가 없었다면) 빈 문자열 → `dirname ""` → `.` → `cd null directory`로 또 실패

즉 이 스크립트는 **파일로 실행되는 것을 전제**(`./install.sh`, `bash install.sh`)로 작성됐는데, README는 **파이프 실행**(`curl | bash`)을 권장하고 있어 둘이 어긋난다.

---

## 3. 우회 방법 (적용한 해결책)

스크립트를 **임시 파일로 먼저 내려받은 뒤 파일로 실행**한다. 이렇게 하면 `BASH_SOURCE[0]`이 정상적으로 그 파일 경로를 가리키게 되어 31번 줄이 통과한다.

```bash
TMP=$(mktemp /tmp/cc-statusline-install.XXXXXX.sh)
curl -fsSL https://raw.githubusercontent.com/AwesomeJun/CC-statusline/main/install.sh -o "$TMP"
bash "$TMP" large          # 사이즈 인자를 직접 전달 (large)
rm -f "$TMP"
```

### 왜 이 방법이 동작하는가

| 단계 | 효과 |
|------|------|
| `mktemp` | 충돌 없는 임시 파일 경로 생성 |
| `curl -o "$TMP"` | 스크립트를 stdin이 아닌 **실제 파일**로 저장 |
| `bash "$TMP" large` | 파일 경로로 실행 → `BASH_SOURCE[0]`이 `$TMP`를 가리킴 ✅, 인자 `large`가 `$1`로 전달되어 사이즈 프롬프트도 건너뜀 |
| `rm -f "$TMP"` | 임시 파일 정리 |

### 실행 결과 (정상)

```
Local scripts/ not found, downloading size 'large' from repo…
Existing settings backed up to: /Users/kang/.claude/settings.json.backup-20260602-144924
Installed Awesome CC Statusline (size: large)
  script:   /Users/kang/.claude/awesome-statusline.sh
  settings: /Users/kang/.claude/settings.json  (statusLine set)
```

> 참고: 로컬에 `scripts/` 폴더가 없으면(임시 파일 단독 실행이므로 당연히 없음) 32번 줄의 `SRC_DIR`가 무의미해지지만, 스크립트는 이 경우 repo에서 해당 사이즈 스크립트를 직접 다운로드하는 fallback 분기를 타므로 설치는 정상 완료된다.

---

## 4. 다른 우회 옵션

상황에 따라 아래도 가능하다.

1. **레포를 클론한 뒤 로컬 실행** (README의 대안 방법) — `BASH_SOURCE[0]`이 채워지고 `scripts/`도 로컬에 존재하므로 가장 깔끔.
   ```bash
   git clone https://github.com/AwesomeJun/CC-statusline.git
   cd CC-statusline && ./install.sh large
   ```
2. **process substitution으로 "파일처럼" 먹이기** (bash 한정)
   ```bash
   bash <(curl -fsSL .../install.sh) large
   ```
   `<(...)`는 `/dev/fd/63` 같은 파일 디스크립터 경로를 만들어 주므로 `BASH_SOURCE[0]`이 그 경로로 채워진다. zsh에서도 동작하지만 일부 셸에서는 미지원.

---

## 5. 근본 수정 (install.sh 패치 — ✅ 적용 완료 2026-06-02)

파이프 실행을 README가 권장하는 한, 스크립트가 `BASH_SOURCE`의 부재를 안전하게 처리해야 한다. 31번 줄을 다음과 같이 방어적으로 고쳐 `curl | bash`에서도 죽지 않게 했다.

```bash
# Before (31번 줄)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# After — 파이프 실행(BASH_SOURCE 미설정) 시 안전하게 fallback
if [ -n "${BASH_SOURCE:-}" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  SCRIPT_DIR=""          # 파이프 실행: 로컬 scripts/ 없음 → repo 다운로드 분기로 진행
fi
SRC_DIR="$SCRIPT_DIR/scripts"
```

`${BASH_SOURCE:-}`의 `:-` 기본값 확장은 `set -u` 하에서도 안전하게 "비어 있는가"를 검사할 수 있게 해 준다. `SCRIPT_DIR`가 비면 `SRC="$SRC_DIR/..."` 파일이 존재하지 않으므로 스크립트는 자연스럽게 repo 다운로드 fallback(130번 줄 부근)을 타게 된다.

### 검증 (적용 후)

`curl | bash`를 흉내 낸 파이프 실행이 31번 줄에서 죽지 않고 설치까지 완료됨을 확인했다.

```bash
cat install.sh | CLAUDE_CONFIG_DIR="$(mktemp -d)" bash -s -- xs
# Local scripts/ not found, downloading size 'xsmall' from repo…
# Installed Awesome CC Statusline (size: xsmall)
#   exit: 0
```

---

## 6. 요약

| 항목 | 내용 |
|------|------|
| **증상** | `curl ... \| bash` 설치 시 `line 31: BASH_SOURCE[0]: unbound variable` |
| **원인** | 파이프 실행 시 `BASH_SOURCE[0]`이 unset인데 `set -u`가 이를 에러로 처리 |
| **우회** | `mktemp`로 임시 파일에 내려받아 `bash <file> <size>`로 실행 |
| **근본 수정** | 31번 줄에 `${BASH_SOURCE:-}` 존재 검사 + fallback 추가 |
