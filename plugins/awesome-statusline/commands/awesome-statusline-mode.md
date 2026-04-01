---
name: awesome-statusline-mode
description: Awesome Statusline 모드를 변경합니다 (compact/default/full/legacy)
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - AskUserQuestion
argument-hint: "[compact|default|full|legacy|restore]"
---

# Awesome Statusline Mode Switcher

Awesome Statusline의 모드를 변경합니다.

## 모드 종류

### 2.1.1 모드 (3가지)

| 모드 | 줄 수 | 바 크기 | 설명 |
|------|-------|---------|------|
| **compact** | 2줄 | 10블록 | 최소 정보, 좁은 터미널용 |
| **default** | 2줄 | 10블록 | 균형잡힌 정보, 대부분의 사용자에게 권장 |
| **full** | 5줄 | 40블록 | 상세 정보 (비용, 시간, Git ahead/behind, 토큰 수) |

### Legacy 모드

| 모드 | 줄 수 | 바 크기 | 설명 |
|------|-------|---------|------|
| **legacy-2.0.1** | 5줄 | 20블록 | 비용, 시간, 토큰 수 표시 |
| **legacy-1.0.3** | 4줄 | 40블록 | 클래식 디자인 |

## 인자 처리

| 인자 | 동작 |
|------|------|
| (없음) | 대화형 모드 선택 |
| `compact` | 2.1.1 Compact 모드로 변경 |
| `default` | 2.1.1 Default 모드로 변경 |
| `full` | 2.1.1 Full 모드로 변경 |
| `legacy` | 대화형 Legacy 버전 선택 |
| `legacy-2.0.1` 또는 `2.0.1` | 2.0.1 Legacy 모드로 변경 |
| `legacy-1.0.3` 또는 `1.0.3` | 1.0.3 Legacy 모드로 변경 |
| `restore` | 가장 최근 백업에서 복원 |

## 사용법

### 인자로 직접 지정
```
/awesome-statusline-mode compact      # Compact 모드로 변경
/awesome-statusline-mode default      # Default 모드로 변경
/awesome-statusline-mode full         # Full 모드로 변경
/awesome-statusline-mode legacy-2.0.1 # 2.0.1 Legacy로 변경
/awesome-statusline-mode legacy-1.0.3 # 1.0.3 Legacy로 변경
/awesome-statusline-mode restore      # 백업에서 복원
```

### 대화형 선택
```
/awesome-statusline-mode           # 모드 선택 UI 표시
```

## 처리 로직

### 1. 인자가 있는 경우

인자에 따라 해당 스크립트를 `~/.claude/awesome-statusline.sh`로 복사:

| 인자 | 소스 스크립트 |
|------|---------------|
| `compact` | `${CLAUDE_PLUGIN_ROOT}/scripts/awesome-statusline-2.1.1-compact.sh` |
| `default` | `${CLAUDE_PLUGIN_ROOT}/scripts/awesome-statusline-2.1.1-default.sh` |
| `full` | `${CLAUDE_PLUGIN_ROOT}/scripts/awesome-statusline-2.1.1-full.sh` |
| `legacy-2.0.1` / `2.0.1` | `${CLAUDE_PLUGIN_ROOT}/scripts/awesome-statusline-2.0.1-legacy.sh` |
| `legacy-1.0.3` / `1.0.3` | `${CLAUDE_PLUGIN_ROOT}/scripts/awesome-statusline-1.0.3-legacy.sh` |

실행 권한 부여 후 완료 메시지 표시.

### 2. 인자가 없는 경우

AskUserQuestion으로 모드 선택:

```
어떤 Statusline 모드를 사용하시겠습니까?

[Compact] - 2줄, 10블록 바, 최소 정보
[Default (Recommended)] - 2줄, 10블록 바, 균형잡힌 정보
[Full] - 5줄, 40블록 바, 상세 정보
[Legacy 2.0.1] - 5줄, 20블록 바, 비용/시간 표시
[Legacy 1.0.3] - 4줄, 클래식 디자인
```

선택 후 해당 스크립트 복사

### 3. restore 인자

가장 최근 백업 파일에서 복원:
- `~/.claude/statusline-backup-*.sh` 검색
- 가장 최근 파일을 `~/.claude/awesome-statusline.sh`로 복사

## 예시 대화

### 인자 사용 - Compact
```
사용자: /awesome-statusline-mode compact

Claude: ✅ Statusline 모드가 **Compact**로 변경되었습니다!

        📁 스크립트: ~/.claude/awesome-statusline.sh
        🎨 모드: Compact (2줄, 10블록 바)

        🔄 Claude Code를 재시작하면 적용됩니다.
```

### 인자 사용 - Default
```
사용자: /awesome-statusline-mode default

Claude: ✅ Statusline 모드가 **Default**로 변경되었습니다!

        📁 스크립트: ~/.claude/awesome-statusline.sh
        🎨 모드: Default (2줄, 10블록 바)

        🔄 Claude Code를 재시작하면 적용됩니다.
```

### 인자 사용 - Full
```
사용자: /awesome-statusline-mode full

Claude: ✅ Statusline 모드가 **Full**로 변경되었습니다!

        📁 스크립트: ~/.claude/awesome-statusline.sh
        🎨 모드: Full (5줄, 40블록 바)

        🔄 Claude Code를 재시작하면 적용됩니다.
```

### 인자 사용 - Legacy
```
사용자: /awesome-statusline-mode legacy

Claude: ✅ Statusline 모드가 **Legacy 1.0.3**로 변경되었습니다!

        📁 스크립트: ~/.claude/awesome-statusline.sh
        🎨 모드: Legacy (4줄, 클래식 디자인)

        🔄 Claude Code를 재시작하면 적용됩니다.
```

### 대화형 선택
```
사용자: /awesome-statusline-mode

Claude: 어떤 Statusline 모드를 사용하시겠습니까?

        [Compact] [Default (Recommended)] [Full] [Legacy 2.0.1] [Legacy 1.0.3]

사용자: Full

Claude: ✅ Statusline 모드가 **Full**로 변경되었습니다!

        📁 스크립트: ~/.claude/awesome-statusline.sh
        🎨 모드: Full (5줄, 40블록 바)

        🔄 Claude Code를 재시작하면 적용됩니다.
```

### 복원
```
사용자: /awesome-statusline-mode restore

Claude: 📦 백업 파일을 찾았습니다:
        1. statusline-backup-20250119_071500.sh (가장 최근)
        2. statusline-backup-20250118_143000.sh

        가장 최근 백업으로 복원하시겠습니까?

        [예] [목록에서 선택]
```

## 중요 사항

- 모드 변경 시 기존 커스텀 스크립트는 덮어씌워집니다
- 커스텀 수정을 유지하려면 백업 후 변경하세요
- Claude Code 재시작 후 적용됩니다
- 첫 설치는 `/awesome-statusline-start` 사용
