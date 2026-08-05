from pathlib import Path
import re
import sys

from PIL import Image


site = Path(sys.argv[1]).resolve()
pattern = re.compile(r"assets/[A-Za-z0-9_./%+()-]+?\.webp(?=[?#\s\"'<)]|$)", re.IGNORECASE)
references: set[str] = set()

for text_file in site.rglob("*"):
    if not text_file.is_file() or text_file.suffix.lower() not in {".html", ".css", ".js", ".xml", ".txt", ".ps1"}:
        continue
    try:
        references.update(pattern.findall(text_file.read_text(encoding="utf-8-sig")))
    except UnicodeDecodeError:
        pass

invalid: list[str] = []
missing_metadata: list[str] = []
old_metadata: list[str] = []
for reference in references:
    image_path = site / Path(reference.replace("/", "\\"))
    try:
        with Image.open(image_path) as image:
            image.verify()
        with Image.open(image_path) as image:
            if "789clubhot.com" not in str(image.getexif().get(270, "")):
                missing_metadata.append(reference)
        content = image_path.read_bytes()
        if b"789clubhot.info" in content or b"789clubhot.org" in content:
            old_metadata.append(reference)
    except Exception as error:
        invalid.append(f"{reference}: {error}")

print(
    f"Referenced WebP: {len(references)}; invalid: {len(invalid)}; "
    f"missing new metadata: {len(missing_metadata)}; old metadata refs: {len(old_metadata)}"
)
if invalid:
    print("\n".join(invalid[:10]))
sys.exit(1 if invalid or missing_metadata or old_metadata else 0)
