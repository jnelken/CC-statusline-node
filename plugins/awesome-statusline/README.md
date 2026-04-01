# Awesome Statusline

[![Claude Code Plugin](https://img.shields.io/badge/Claude%20Code-Plugin-blueviolet)](https://claude.ai/code)
[![Version](https://img.shields.io/badge/version-2.1.1-blue)](https://github.com/awesomejun/awesome-claude-plugins)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

![Awesome Statusline](assets/hero.jpeg)

Beautiful **Catppuccin-themed statusline** for Claude Code with **5 display modes** and real-time API usage monitoring.

## ✨ Features

- 🎨 **5 Display Modes**: Compact, Default, Full, Legacy 2.0.1, Legacy 1.0.3
- 🌈 **Catppuccin Mocha Theme**: Beautiful 4-stage gradient progress bars
- 📊 **Real-time Monitoring**: Model, Git status, Context usage, API limits (5H/7D)
- 🔄 **Easy Mode Switching**: `/awesome-statusline-mode` command
- 💾 **Auto-backup**: Automatically backs up existing statusline
- 🌟 **Dynamic Colors**: Percentage numbers match gradient end color (Bold)

## 📐 Display Modes

### Full (Long) - 5 lines, 40-block bars

![Full Mode](assets/demo-full.png)

The most detailed mode with cost tracking, session duration, and full reset time information.

### Default - 2 lines, 10-block bars

![Default Mode](assets/demo-default.png)

Balanced information display with compact progress bars and short reset times.

### Compact (Short) - 2 lines, 10-block bars

![Compact Mode](assets/demo-compact.png)

Minimal display for narrow terminals or distraction-free coding.

### Legacy 2.0.1 - 5 lines, 20-block bars

5-line display with cost tracking, session duration, and token counts. Uses 20-block progress bars.

### Legacy 1.0.3 - 4 lines, 40-block bars

![Legacy Mode](assets/demo-legacy.png)

Classic design with simple gradient colors.

## 🚀 Installation

### Via Marketplace

```bash
# Add marketplace
/plugin marketplace add awesomejun/awesome-claude-plugins

# Install plugin
/plugin install awesome-statusline@awesome-claude-plugins

# Restart Claude Code
claude

# Run setup wizard
/awesome-statusline-start
```

## 🔧 Usage

### Initial Setup

```bash
/awesome-statusline-start           # Interactive setup wizard
/awesome-statusline-start compact   # Install Compact mode directly
/awesome-statusline-start default   # Install Default mode directly
/awesome-statusline-start full      # Install Full mode directly
/awesome-statusline-start legacy-2.0.1  # Install 2.0.1 Legacy mode
/awesome-statusline-start legacy-1.0.3  # Install 1.0.3 Legacy mode
/awesome-statusline-start restore   # Restore from backup
```

### Switch Mode

```bash
/awesome-statusline-mode compact   # Compact mode
/awesome-statusline-mode default   # Default mode
/awesome-statusline-mode full      # Full mode
/awesome-statusline-mode legacy-2.0.1  # 2.0.1 Legacy mode
/awesome-statusline-mode legacy-1.0.3  # 1.0.3 Legacy mode
/awesome-statusline-mode restore   # Restore from backup

/awesome-statusline-mode           # Interactive selection
```

## 📊 Mode Comparison

| Feature | Compact | Default | Full | Legacy 2.0 | Legacy 1.0 |
|---------|---------|---------|------|------------|------------|
| Lines | 2 | 2 | 5 | 5 | 4 |
| Bar Width | 10 blocks | 10 blocks | 40 blocks | 20 blocks | 40 blocks |
| Model | Short (Opus) | Full (Opus 4.5) | Full | Full | Full |
| Output Style | ❌ | ✅ | ✅ | ✅ | ✅ |
| Git Status | Icon only | Icon only | Detailed | Detailed | Simple |
| Git ↑↓ (ahead/behind) | ❌ | ❌ | ✅ | ❌ | ❌ |
| Conda Env | ❌ | ❌ | ✅ | ✅ | ✅ |
| Cost | ❌ | ❌ | ✅ | ✅ | ❌ |
| Duration | ❌ | ❌ | ✅ | ✅ | ❌ |
| Reset Time | ❌ | Short (1h2m) | Full | Full | Short |
| % Bold+Gradient | ❌ | ✅ | ✅ | ✅ | ✅ |

## 🌈 Gradient Colors

### 2.1.1 Modes (Compact, Default, Full)

4-stage gradients that change based on usage level:

| Bar | 0-40% | 40-80% | 80-100% |
|-----|-------|--------|---------|
| **Context** | Mocha Maroon | Latte Maroon | Latte Red |
| **5H Limit** | Mocha Lavender | Latte Blue | Latte Red |
| **7D Limit** | Mocha Yellow | Latte Green | Latte Red |

### 1.0.3 Legacy

| Bar | 0-50% | 50-100% |
|-----|-------|---------|
| **Context** | Latte Yellow | Latte Red → Mauve |
| **Usage (5H/7D)** | Mocha Green | Latte Teal → Blue |

## 📋 Requirements

- Claude Code CLI
- macOS / Windows / Linux
- `jq` (자동 설치됨)

## 🗑️ Uninstall

상태 표시줄을 해제하거나 삭제하려면:

```bash
/awesome-statusline-remove          # 대화형 선택
/awesome-statusline-remove settings # 설정만 해제 (스크립트 유지)
/awesome-statusline-remove all      # 완전 삭제
```

## 📄 License

MIT License - See [LICENSE](LICENSE) file
