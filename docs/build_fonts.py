#!/usr/bin/env python3
"""Render the `large` preset across popular & OS-default monospace fonts.

Generates docs/fonts.html (captured to assets/fonts-demo.png) so users can see
how the statusline looks in cross-platform webfonts AND the system fonts their
terminal likely ships with by default.
"""
import subprocess, re, html as H, os, pathlib, time

ROOT = pathlib.Path(__file__).resolve().parent.parent
os.chdir(ROOT)
_BRANCH = subprocess.run(["git", "branch", "--show-current"],
                         capture_output=True, text=True).stdout.strip()
_now = int(time.time())
MOCK = (
    '{"model":{"display_name":"Opus 4.8"},'
    '"workspace":{"current_dir":"%s"},'
    '"context_window":{"context_window_size":1000000,'
    '"current_usage":{"input_tokens":320000,"output_tokens":28000,'
    '"cache_creation_input_tokens":0,"cache_read_input_tokens":0}},'
    '"cost":{"total_cost_usd":25.29,"total_duration_ms":18960000},'
    '"output_style":{"name":"explanatory"},'
    '"effort":{"level":"xhigh"},"thinking":{"enabled":true},'
    '"rate_limits":{"five_hour":{"used_percentage":34,"resets_at":%d},'
    '"seven_day":{"used_percentage":65,"resets_at":%d}}}'
) % (str(ROOT), _now + 16560, _now + 230400)

ANSI = re.compile(r'(\x1b\[[0-9;]*m)')


def render(size: str) -> str:
    p = subprocess.run(["bash", f"scripts/awesome-statusline-{size}.sh"],
                       input=MOCK, capture_output=True, text=True)
    out = p.stdout.replace(str(ROOT), "~/cc/awesome-statusline")
    out = out.replace(os.path.expanduser("~"), "~").replace("kang", "you")
    if _BRANCH and _BRANCH != "main":
        out = out.replace(_BRANCH, "main")
    return out


def ansi_to_html(s: str) -> str:
    color = None
    bold = False
    out = []

    def op():
        st = []
        if color:
            st.append(f"color:rgb({color[0]},{color[1]},{color[2]})")
        if bold:
            st.append("font-weight:700")
        return f'<span style="{";".join(st)}">' if st else "<span>"

    for tok in ANSI.split(s):
        if tok.startswith("\x1b["):
            codes = tok[2:-1].split(";")
            j = 0
            while j < len(codes):
                c = codes[j] or "0"
                if c == "0":
                    color = None
                    bold = False
                elif c == "1":
                    bold = True
                elif c == "38" and j + 2 < len(codes) and codes[j + 1] == "2":
                    color = (int(codes[j + 2]), int(codes[j + 3]), int(codes[j + 4]))
                    j += 4
                j += 1
        elif tok:
            txt = tok.replace("\x1b[K", "").replace("\r", "")
            if txt:
                out.append(op() + H.escape(txt) + "</span>")
    return "".join(out)


LARGE = "".join(f'<div class="row">{ansi_to_html(ln)}</div>'
                for ln in render("large").rstrip("\n").split("\n"))

D2 = os.path.expanduser("~/Library/Fonts/D2CodingLigatureNerdFontMono")

# (display name, css font-family, note, google_query | None, local_face | None)
FONTS = [
    # — cross-platform webfonts (Google Fonts) —
    ("JetBrains Mono",  "'JetBrains Mono'",  "Google Fonts · repo default", "JetBrains+Mono", None),
    ("Fira Code",       "'Fira Code'",       "Google Fonts · ligatures", "Fira+Code", None),
    ("Cascadia Code",   "'Cascadia Code'",   "Google Fonts · Windows Terminal", "Cascadia+Code", None),
    ("Source Code Pro", "'Source Code Pro'", "Google Fonts · Adobe", "Source+Code+Pro", None),
    ("IBM Plex Mono",   "'IBM Plex Mono'",   "Google Fonts · IBM", "IBM+Plex+Mono", None),
    ("Roboto Mono",     "'Roboto Mono'",     "Google Fonts · Google", "Roboto+Mono", None),
    ("Ubuntu Mono",     "'Ubuntu Mono'",     "Google Fonts · Ubuntu default", "Ubuntu+Mono", None),
    ("Inconsolata",     "'Inconsolata'",     "Google Fonts · classic", "Inconsolata", None),
    ("Space Mono",      "'Space Mono'",      "Google Fonts · geometric", "Space+Mono", None),
    # — system / OS-default fonts (no install needed on that OS) —
    ("SF Mono",         "'.SF NS Mono','SF Mono'", "macOS Terminal default", None, None),
    ("Menlo",           "Menlo",             "macOS · VS Code default", None, None),
    ("Monaco",          "Monaco",            "classic macOS", None, None),
    ("MesloLGS Nerd Font", "'MesloLGS Nerd Font'", "Powerlevel10k / oh-my-zsh", None, None),
    ("Courier New",     "'Courier New'",     "universal classic", None, None),
    ("D2Coding",        "'D2Coding'",        "Korean · Naver (local)", None, D2),
]

links = "\n".join(
    f'<link href="https://fonts.googleapis.com/css2?family={q}:wght@400;700&display=swap" rel="stylesheet">'
    for *_, q, _f in FONTS if q
)
font_faces = "".join(
    f"@font-face{{font-family:'D2Coding';font-weight:400;src:url('file://{face}-Regular.ttf')}}"
    f"@font-face{{font-family:'D2Coding';font-weight:700;src:url('file://{face}-Bold.ttf')}}"
    for *_, _q, face in FONTS if face
)

def make_cards(items, start):
    return "\n".join(
        f'''  <div class="card">
    <div class="fname">{i+start+1}. {name} <span class="src">{note}</span></div>
    <div class="term" style="font-family:{fam},'Apple Color Emoji',monospace">{LARGE}</div>
  </div>'''
        for i, (name, fam, note, _q, _f) in enumerate(items)
    )


N_GOOGLE = sum(1 for *_, q, _f in FONTS if q)
cards_google = make_cards(FONTS[:N_GOOGLE], 0)
cards_system = make_cards(FONTS[N_GOOGLE:], N_GOOGLE)

HTML = f'''<!DOCTYPE html>
<html lang="en"><head><meta charset="UTF-8" />
{links}
<style>
  {font_faces}
  *{{box-sizing:border-box;margin:0;padding:0}}
  body{{background:radial-gradient(900px 500px at 50% -10%,#25253a,#181825 60%,#11111b);
    color:#cdd6f4;font-family:-apple-system,"Segoe UI",sans-serif;padding:48px 24px}}
  .wrap{{max-width:1080px;margin:0 auto}}
  h1{{text-align:center;font-size:30px;font-weight:800;letter-spacing:-.5px;margin-bottom:8px}}
  h1 .s{{color:#fab387}}
  p.sub{{text-align:center;color:#a6adc8;font-size:15px;margin-bottom:30px}}
  p.sub code{{color:#94e2d5}}
  .group{{text-align:center;text-transform:uppercase;letter-spacing:2px;font-size:12px;
    color:#6c7086;margin:34px 0 14px}}
  .card{{background:#181825;border:1px solid #313244;border-radius:14px;overflow:hidden;
    margin-bottom:16px;box-shadow:0 14px 40px -22px rgba(0,0,0,.7)}}
  .fname{{padding:11px 16px;font-weight:700;font-size:13.5px;color:#cba6f7;
    border-bottom:1px solid #313244}}
  .fname .src{{color:#6c7086;font-weight:500;font-size:12px;margin-left:6px}}
  .term{{background:#1e1e2e;padding:14px 16px;font-size:13.5px;line-height:1.95;
    white-space:pre;overflow-x:auto}}
  .term .row{{display:block}}
</style></head><body>
<div class="wrap">
  <h1><span class="s">⚡</span> Awesome Statusline — one preset, many fonts</h1>
  <p class="sub">The <code>large</code> preset, same data, only the font changes. It's font-agnostic — it just uses your terminal's font.</p>
  <div class="group">Cross-platform webfonts (Google Fonts)</div>
{cards_google}
  <div class="group">System / OS-default fonts</div>
{cards_system}
</div></body></html>
'''

(ROOT / "docs" / "fonts.html").write_text(HTML, encoding="utf-8")
print("wrote docs/fonts.html with", len(FONTS), "fonts")
