from pathlib import Path
import re
import sys

from PIL import Image


site = Path(sys.argv[1]).resolve()
text_extensions = {".html", ".css", ".js", ".xml", ".txt", ".ps1"}
pattern = re.compile(r"assets/[A-Za-z0-9_./%+()-]+?\.(?:png|jpe?g|webp)(?=[?#\s\"'<)]|$)", re.IGNORECASE)

references: dict[str, str] = {}
for text_file in site.rglob("*"):
    if not text_file.is_file() or text_file.suffix.lower() not in text_extensions:
        continue
    try:
        content = text_file.read_text(encoding="utf-8-sig")
    except UnicodeDecodeError:
        continue
    for match in pattern.finditer(content):
        old_ref = match.group(0)
        source = site / Path(old_ref.replace("/", "\\"))
        if source.exists():
            references[old_ref] = str(Path(old_ref).with_suffix(".webp")).replace("\\", "/")

converted = 0
rerendered = 0
for old_ref, new_ref in sorted(references.items()):
    source = site / Path(old_ref.replace("/", "\\"))
    destination = site / Path(new_ref.replace("/", "\\"))
    destination.parent.mkdir(parents=True, exist_ok=True)
    with Image.open(source) as image:
        image.load()
        exif = Image.Exif()
        exif[270] = "789Club - https://789clubhot.com/"
        exif[305] = "789clubhot.com WebP renderer"
        exif[315] = "789Club"
        target = destination
        if source.resolve() == destination.resolve():
            target = destination.with_name(destination.stem + ".rerender.webp")
        image.save(target, "WEBP", quality=90, method=6, lossless=image.mode in {"RGBA", "LA", "P"}, exif=exif)
    if target != destination:
        target.replace(destination)
        rerendered += 1
    else:
        converted += 1

updated_files = 0
for text_file in site.rglob("*"):
    if not text_file.is_file() or text_file.suffix.lower() not in text_extensions:
        continue
    try:
        content = text_file.read_text(encoding="utf-8-sig")
    except UnicodeDecodeError:
        continue
    updated = content
    for old_ref, new_ref in references.items():
        updated = updated.replace(old_ref, new_ref)
    if updated != content:
        text_file.write_text(updated, encoding="utf-8", newline="")
        updated_files += 1

print(f"New WebP: {converted}; rerendered WebP: {rerendered}; updated reference files: {updated_files}")
