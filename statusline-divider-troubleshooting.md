# Statusline 구분선 끊김 트러블슈팅

> **작성일**: 2026-06-02
> **대상 파일**: 레포 배포 소스 `scripts/awesome-statusline-{small,medium,large,xlarge}.sh` (설치본 `~/.claude/awesome-statusline.sh`는 재설치 시 이 소스로 덮어써짐). `xsmall`은 구분선을 쓰지 않아 대상 아님.
> **증상**: statusline의 세그먼트(Model / Git / Env / Style, Dir / Cost / Duration) 사이 세로 구분선이 **중간이 끊겨 보임**

---

## 1. 증상 (Symptom)

statusline 한 줄에서 세그먼트를 나누는 세로 구분선이 위아래로 온전히 이어지지 않고
가운데가 끊긴(broken) 모양으로 렌더링됨.

```
🤖 Opus 4.8 | ✅ Git | 🐍 Env | 🎨 Style
            ↑ 이 구분선이 가운데 끊겨 보임
```

---

## 2. 근본 원인 (Root Cause)

구분선이 **ASCII 파이프 문자 `|` (U+007C, VERTICAL LINE)** 로 그려지고 있었음.

- `|` 글리프는 폰트마다 **줄 높이(line-height)보다 짧게** 디자인된 경우가 많다.
- 일부 프로그래밍/터미널 폰트는 이 문자를 **"broken bar(¦)" 스타일** — 가운데가 끊긴 모양 — 으로 그린다.
- 즉, 코드/스크립트의 버그가 아니라 **글자(글리프) 선택 문제**다.

### 대비: 박스 드로잉 세로선
`│` (U+2502, BOX DRAWINGS LIGHT VERTICAL)는 터미널 TUI가 테두리(`┌ ┐ └ ┘ ─ │`)를 그릴 때 쓰는
박스 드로잉 세트의 일부로, **줄 높이를 꽉 채워 끊김 없이 이어지도록** 설계되어 있다.

| 문자 | 코드포인트 | UTF-8 바이트 | 특징 |
|------|-----------|-------------|------|
| `\|` | U+007C | `0x7C` (1바이트) | ASCII, 글리프 짧음 → 끊겨 보임 |
| `│` | U+2502 | `0xE2 0x94 0x82` (3바이트) | 박스 드로잉, 연속선 |
| `┃` | U+2503 | `0xE2 0x94 0x83` (3바이트) | 굵은 버전 (더 확실) |

---

## 3. 진단 과정 (Diagnosis)

### Step 1. statusline 설정 방식 확인
```bash
cat ~/.claude/settings.json | python3 -c "import sys,json; print(json.load(sys.stdin).get('statusLine'))"
# → {"type":"command","command":"~/.claude/awesome-statusline.sh"}
```
statusline이 **스크립트 명령 방식**임을 확인. → 스크립트 내부에서 구분선을 찾아야 함.

### Step 2. 스크립트에서 구분선 위치 grep
```bash
# 레포 배포 소스 전체를 검사 (설치본은 이 소스에서 복사됨)
grep -nF ' | ' scripts/awesome-statusline-*.sh
```

`LINE1`/`LINE2`/`*_DISPLAY` 조립 라인에서 `${VAR} | ${VAR}` 형태의 ASCII 파이프 사용 발견. **셸 파이프(`echo "$input" | jq`)·정규식·주석의 `|`는 구분선이 아니므로 절대 건드리면 안 된다.**

사이즈별 구분선 라인 (레포 소스 기준):

| 파일 | 구분선 라인 |
|------|------------|
| `large.sh`  | 190 (LINE1), 232 (LINE2) |
| `medium.sh` | 188 (OUTPUT_STYLE_DISPLAY), 191 (LINE1), 282 (LINE4 통계) |
| `small.sh`  | 157 (STYLE_DISPLAY), 191 (LINE1), 256·264 (LINE2) |
| `xlarge.sh` | 233·234 (LINE1), 274 (LINE2) |
| `xsmall.sh` | — (구분선 미사용) |

```sh
# 예: large.sh
LINE1="${MODEL_DISPLAY} | ${GIT_STATUS_DISPLAY} | ${ENV_DISPLAY} | ${STYLE_DISPLAY}"
LINE2="${DIR_DISPLAY}${BRANCH_DISPLAY} | ${COST_DISPLAY} | ${DURATION_DISPLAY}"
```

---

## 4. 수정 (Fix)

화면 출력 구분선 ` | ` 만 박스 드로잉 세로선 ` │ ` 로 교체 (앞뒤 공백 유지). 위 표의 모든 사이즈 라인에 동일 적용하되, **셸 파이프·정규식·주석의 `|`는 그대로 둔다.** `sed`/`perl -pi` 같은 전역 치환은 셸 파이프까지 깨뜨리므로 금지 — 구분선 라인만 정확히 교체한다.

```diff
- LINE1="${MODEL_DISPLAY} | ${GIT_STATUS_DISPLAY} | ${ENV_DISPLAY} | ${STYLE_DISPLAY}"
+ LINE1="${MODEL_DISPLAY} │ ${GIT_STATUS_DISPLAY} │ ${ENV_DISPLAY} │ ${STYLE_DISPLAY}"

- LINE2="${DIR_DISPLAY}${BRANCH_DISPLAY} | ${COST_DISPLAY} | ${DURATION_DISPLAY}"
+ LINE2="${DIR_DISPLAY}${BRANCH_DISPLAY} │ ${COST_DISPLAY} │ ${DURATION_DISPLAY}"
```

> 적용 범위: `small` / `medium` / `large` / `xlarge` 4종. `v3.2.5`에서 레포 소스에 반영됨.

---

## 5. 검증 (Verification)

샘플 JSON을 stdin으로 흘려 실제 렌더 결과를 raw 바이트로 확인.

```bash
echo '{"model":{"display_name":"Opus 4.8"},"workspace":{"current_dir":"/Users/kang"},"output_style":{"name":"Explanatory"},"cost":{"total_cost_usd":0.12,"total_duration_ms":45000}}' \
  | bash ~/.claude/awesome-statusline.sh 2>/dev/null | cat -v | head -2
```

`cat -v` 출력에서 구분선 위치 바이트가 `M-^TM-^B` (= `\xe2\x94\x82` = U+2502 `│`)로 바뀐 것을 확인.
→ 기존 1바이트 `0x7C`(`|`)에서 3바이트 UTF-8 박스 드로잉 문자로 정확히 치환됨.

statusline은 **매 렌더마다 스크립트를 다시 실행**하므로 재시작 없이 다음 갱신부터 적용됨.

---

## 6. 추가 옵션 (Variants)

폰트에 따라 `│`마저 미세 간격이 보이면 줄 간격(line-height) 영향일 수 있음. 다음으로 교체 가능:

| 원하는 스타일 | 문자 | 코드포인트 |
|--------------|------|-----------|
| 굵게 (가장 확실) | `┃` | U+2503 |
| 이중선 | `║` | U+2551 |
| 점선 | `┊` | U+250A |

교체는 동일하게 185/227행의 구분 문자만 바꾸면 됨.

---

## 7. 교훈 (Lesson)

- statusline 같은 텍스트 UI에서 "끊겨 보임 / 어긋나 보임"은 **코드 로직이 아니라 글리프 선택** 문제인 경우가 많다.
- 세로/가로선·테두리는 ASCII(`| - +`) 대신 **박스 드로잉 문자(`│ ─ ┼` 등)** 를 쓰는 것이 정석.
- 수정 후에는 `cat -v`로 **raw 바이트를 직접 확인**해서 의도한 코드포인트로 치환됐는지 검증한다 (터미널에서 눈으로만 보면 폰트 렌더링에 속을 수 있음).
