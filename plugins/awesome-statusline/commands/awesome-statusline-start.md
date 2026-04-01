---
name: awesome-statusline-start
description: Awesome Statusline 설치 마법사 - 버전, 모드, 커스터마이징 선택
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - AskUserQuestion
argument-hint: "[compact|default|full|legacy|restore]"
---

# Awesome Statusline Setup Wizard

Claude Code의 Awesome Statusline을 설치하는 대화형 마법사입니다.

## 버전 정보

| 버전 | 모드 | 설명 |
|------|------|------|
| **2.1.1** (최신) | Compact / Default / Full | 3-mode 시스템, 4단계 그라데이션 |
| **2.0.1** (Legacy) | Single | 5줄 20블록, 비용/시간 표시 |
| **1.0.3** (Legacy) | Single | 4줄 클래식 디자인 |

## 2.1.1 모드 상세

| 모드 | 줄 수 | 바 크기 | 설명 |
|------|-------|---------|------|
| **Compact** | 2줄 | 10블록 | 최소 정보, 좁은 터미널용 |
| **Default** | 2줄 | 10블록 | 균형잡힌 정보, 대부분의 사용자에게 권장 |
| **Full** | 5줄 | 40블록 | 상세 정보 (비용, 시간, Git ahead/behind, 토큰 수) |

## Legacy 모드 상세

| 모드 | 줄 수 | 바 크기 | 설명 |
|------|-------|---------|------|
| **Legacy 2.0.1** | 5줄 | 20블록 | 비용, 시간, 토큰 수 표시 (ahead/behind 없음) |
| **Legacy 1.0.3** | 4줄 | 40블록 | 오리지널 클래식 디자인 |

## 설정 플로우

### Step 0: 의존성 자동 설치

설치 시작 전에 **jq**가 설치되어 있는지 확인하고, 없으면 **자동으로 설치**합니다.

```bash
# jq 설치 확인 - 없으면 자동 설치
if ! command -v jq &> /dev/null; then
    echo "📦 jq 설치 중..."
    # 플랫폼별 자동 설치
fi
```

**플랫폼별 자동 설치 (묻지 않고 실행):**

| 플랫폼 | 패키지 매니저 | 명령어 |
|--------|---------------|--------|
| macOS | Homebrew | `brew install jq` |
| Windows | Chocolatey | `choco install jq -y` |
| Windows | Scoop | `scoop install jq` |
| Windows | winget | `winget install jqlang.jq --silent` |
| Ubuntu/Debian | apt | `sudo apt-get install -y jq` |
| Fedora/RHEL | dnf | `sudo dnf install -y jq` |
| Arch Linux | pacman | `sudo pacman -S --noconfirm jq` |

**자동 설치 로직:**

```bash
install_jq() {
    echo "📦 jq가 필요합니다. 자동으로 설치합니다..."

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            brew install jq
        else
            echo "❌ Homebrew가 없습니다. https://brew.sh 에서 먼저 설치하세요."
            return 1
        fi
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
        # Windows (Git Bash, Cygwin, etc.)
        if command -v choco &> /dev/null; then
            choco install jq -y
        elif command -v scoop &> /dev/null; then
            scoop install jq
        elif command -v winget &> /dev/null; then
            winget install jqlang.jq --silent --accept-package-agreements
        else
            echo "❌ 패키지 매니저가 없습니다. choco, scoop, 또는 winget을 설치하세요."
            return 1
        fi
    elif [[ -f /etc/debian_version ]]; then
        sudo apt-get update && sudo apt-get install -y jq
    elif [[ -f /etc/fedora-release ]]; then
        sudo dnf install -y jq
    elif [[ -f /etc/arch-release ]]; then
        sudo pacman -S --noconfirm jq
    else
        echo "❌ 지원하지 않는 플랫폼입니다. jq를 수동으로 설치하세요: https://jqlang.github.io/jq/download/"
        return 1
    fi

    echo "✅ jq 설치 완료!"
}

# jq 없으면 자동 설치
command -v jq &> /dev/null || install_jq
```

**설치 실패 시:**
- 에러 메시지와 수동 설치 링크 제공: https://jqlang.github.io/jq/download/
- 설치 마법사 중단 (jq 없이는 statusline 작동 불가)

### Step 1: 버전 선택

AskUserQuestion으로 물어봅니다:

```
어떤 버전을 설치하시겠습니까?

[2.1.1 (Recommended)] - 3-mode 시스템, Catppuccin 4단계 그라데이션
[1.0.3 Legacy] - 클래식 디자인, 2단계 그라데이션
```

### Step 2a: 2.1.1 선택 시 - 모드 선택

```
어떤 모드로 시작하시겠습니까?

[Compact] - 2줄, 10블록 바, 최소 정보
[Default (Recommended)] - 2줄, 10블록 바, 균형잡힌 정보
[Full] - 5줄, 40블록 바, 상세 정보
```

### Step 2b: 모드 선택 후 - 설치 방식

```
설치 방식을 선택하세요:

[기본 설치 (Recommended)] - 선택한 모드 바로 설치
[커스터마이즈] - 색상, 표시 정보 등 커스텀 설정
```

### Step 2c: Legacy 선택 시

Legacy 버전 선택 대화:
```
어떤 Legacy 버전을 설치하시겠습니까?

[2.0.1] - 5줄, 20블록 바, 비용/시간 표시
[1.0.3] - 4줄, 40블록 바, 클래식 디자인
```

Legacy 스크립트 설치:
- 2.0.1: `${CLAUDE_PLUGIN_ROOT}/scripts/awesome-statusline-2.0.1-legacy.sh`
- 1.0.3: `${CLAUDE_PLUGIN_ROOT}/scripts/awesome-statusline-1.0.3-legacy.sh`

## 처리 로직

### 인자 처리

| 인자 | 동작 |
|------|------|
| (없음) | 대화형 버전/모드 선택 시작 |
| `compact` | 2.1.1 Compact 모드 바로 설치 |
| `default` | 2.1.1 Default 모드 바로 설치 |
| `full` | 2.1.1 Full 모드 바로 설치 |
| `legacy` | 대화형 Legacy 버전 선택 |
| `legacy-2.0.1` 또는 `2.0.1` | 2.0.1 Legacy 바로 설치 |
| `legacy-1.0.3` 또는 `1.0.3` | 1.0.3 Legacy 바로 설치 |
| `restore` | 가장 최근 백업에서 복원 |

### 설치 경로

**2.1.1 버전:**
- Compact: `${CLAUDE_PLUGIN_ROOT}/scripts/awesome-statusline-2.1.1-compact.sh`
- Default: `${CLAUDE_PLUGIN_ROOT}/scripts/awesome-statusline-2.1.1-default.sh`
- Full: `${CLAUDE_PLUGIN_ROOT}/scripts/awesome-statusline-2.1.1-full.sh`

**Legacy 버전:**
- 2.0.1: `${CLAUDE_PLUGIN_ROOT}/scripts/awesome-statusline-2.0.1-legacy.sh`
- 1.0.3: `${CLAUDE_PLUGIN_ROOT}/scripts/awesome-statusline-1.0.3-legacy.sh`

모든 버전은 `~/.claude/awesome-statusline.sh`로 복사됩니다.

### settings.json 업데이트

```json
"statusLine": {
  "type": "command",
  "command": "~/.claude/awesome-statusline.sh"
}
```

## 기존 설정 백업

기존 statusline이 있으면 자동 백업:

```bash
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
EXISTING_SCRIPT=$(jq -r '.statusLine.command // empty' ~/.claude/settings.json)
if [[ -n "$EXISTING_SCRIPT" && -f "${EXISTING_SCRIPT/#\~/$HOME}" ]]; then
    cp "${EXISTING_SCRIPT/#\~/$HOME}" ~/.claude/statusline-backup-${TIMESTAMP}.sh
fi
jq '.statusLine' ~/.claude/settings.json > ~/.claude/statusline-backup-${TIMESTAMP}.json
```

## 예시 대화

### 기본 설치 (2.1.1)
```
사용자: /awesome-statusline-start

Claude: 안녕하세요! Awesome Statusline 설치 마법사입니다. 🎨

        어떤 버전을 설치하시겠습니까?

        [2.1.1 (Recommended)] [1.0.3 Legacy]

사용자: 2.1.1

Claude: 어떤 모드로 시작하시겠습니까?

        [Compact] [Default (Recommended)] [Full]

사용자: Full

Claude: 설치 방식을 선택하세요:

        [기본 설치 (Recommended)] [커스터마이즈]

사용자: 기본 설치

Claude: ✅ Awesome Statusline 2.1.1 Full 모드가 설치되었습니다!

        📁 스크립트: ~/.claude/awesome-statusline.sh
        🎨 모드: Full (5줄, 40블록 바)

        🔄 Claude Code를 재시작하면 적용됩니다.

        💡 모드 변경: /awesome-statusline-mode
```

### 빠른 설치 (인자 사용)
```
사용자: /awesome-statusline-start default

Claude: ✅ Awesome Statusline 2.1.1 Default 모드가 설치되었습니다!

        📁 스크립트: ~/.claude/awesome-statusline.sh
        🎨 모드: Default (2줄, 10블록 바)

        🔄 Claude Code를 재시작하면 적용됩니다.

        💡 모드 변경: /awesome-statusline-mode
```

### Legacy 설치
```
사용자: /awesome-statusline-start legacy

Claude: ✅ Awesome Statusline 1.0.3 Legacy가 설치되었습니다!

        📁 스크립트: ~/.claude/awesome-statusline.sh
        🎨 버전: 1.0.3 (클래식 디자인, 4줄)

        🔄 Claude Code를 재시작하면 적용됩니다.

        💡 2.1.1으로 업그레이드: /awesome-statusline-start
```

### 커스터마이즈 선택 시

**테마 선택:**
- Catppuccin Mocha (기본, 다크 테마)
- Catppuccin Latte (라이트 테마)
- 사용자 정의

**표시할 정보 선택 (multiSelect):**
- 모델 정보 (🤖 Opus 4.5)
- Git 상태 (✅ clean / 📝 dirty)
- 가상 환경 (🐍 env-name)
- Output Style (🎨 learning)
- 디렉토리 경로 (📂 path)
- Git 브랜치 (🌿 branch)
- Context 사용량 (🧠 progress bar)
- API 사용량 (🚀 5H / ⭐ 7D progress bars)

**프로그레스 바 스타일:**
- 4단계 그라데이션 (기본)
- 2단계 그라데이션
- 단색

## 복원 (Restore)

```
사용자: /awesome-statusline-start restore

Claude: 📦 백업 파일을 찾았습니다:
        1. statusline-backup-20250119_052500.sh (가장 최근)
        2. statusline-backup-20250118_143000.sh

        [가장 최근 백업으로 복원] [목록에서 선택]
```

## 중요 사항

- **jq 필수**: 설치 시 자동으로 jq 의존성 확인 및 설치 안내
- 기존 statusline은 자동으로 백업됩니다
- 백업 위치: `~/.claude/statusline-backup-{timestamp}.*`
- 모드 변경은 `/awesome-statusline-mode` 사용
- Claude Code 재시작 후 적용됩니다

## 문제 해결

### 모델명/디렉토리가 안 보이는 경우
```bash
# jq 설치 확인
which jq && jq --version

# 없으면 설치
brew install jq           # macOS
choco install jq -y       # Windows (Chocolatey)
scoop install jq          # Windows (Scoop)
winget install jqlang.jq  # Windows (winget)
sudo apt install jq       # Ubuntu/Debian
```

### Limit이 N/A로 표시되는 경우
OAuth 토큰이 없는 경우입니다. API 키 사용자는 Limit 정보를 볼 수 없습니다.
