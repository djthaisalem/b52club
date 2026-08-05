from pathlib import Path
import re
import sys


site = Path(sys.argv[1]).resolve()
html_files = sorted(site.glob("*.html"))


def minify_css(css: str) -> str:
    css = re.sub(r"/\*(?!\!)[\s\S]*?\*/", "", css)
    css = re.sub(r"\s+", " ", css)
    css = re.sub(r"\s*([{}:;,>])\s*", r"\1", css)
    return css.replace(";}", "}").strip()


def minify_html(source: str) -> str:
    source = re.sub(
        r"(?is)<style([^>]*)>(.*?)</style>",
        lambda match: f"<style{match.group(1)}>{minify_css(match.group(2))}</style>",
        source,
    )
    protected: list[str] = []

    def protect(match: re.Match[str]) -> str:
        protected.append(match.group(0))
        return f"___HTML_PROTECTED_{len(protected) - 1}___"

    source = re.sub(r"(?is)<(?:script|pre|textarea)\b[^>]*>.*?</(?:script|pre|textarea)>", protect, source)
    source = re.sub(r"(?s)<!--(?!\[if).*?-->", "", source)
    source = re.sub(r">\s+<", "><", source)
    source = re.sub(r"[ \t]{2,}", " ", source)
    source = re.sub(r"\n\s*", "", source).strip()

    for index, block in enumerate(protected):
        source = source.replace(f"___HTML_PROTECTED_{index}___", block)
    return source + "\n"


before = 0
after = 0
for html_file in html_files:
    content = html_file.read_text(encoding="utf-8-sig")
    before += len(content.encode("utf-8"))
    result = minify_html(content)
    if not re.match(r"^\s*<!DOCTYPE html>", result, re.IGNORECASE):
        result = "<!DOCTYPE html>" + result
    html_file.write_text(result, encoding="utf-8", newline="")
    after += len(result.encode("utf-8"))

saved = before - after
percent = (saved / before * 100) if before else 0
print(f"Minified HTML: {len(html_files)} files; saved: {saved} bytes ({percent:.1f}%)")
