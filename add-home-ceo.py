from pathlib import Path
import re

page = Path(r"E:\2026\codex\baccarat\789clubhot\index.html")
html = page.read_text(encoding="utf-8")

card = '''<section id="ceo-789club" aria-labelledby="ceo-789club-title" style="padding:40px 20px;background:#0d1420;color:#fff"><div style="max-width:920px;margin:auto;display:flex;align-items:center;gap:26px;padding:22px;border:1px solid #d99e17;border-radius:14px;background:#172232"><img src="assets/hua-hoa-hong-ceo-789club.webp" alt="Hứa Hoà Hồng - CEO 789Club" width="160" height="160" loading="lazy" style="width:160px;height:160px;flex:0 0 160px;object-fit:cover;border:3px solid #f5bb1f;border-radius:50%"><div><p style="margin:0 0 8px;color:#f6c341;font-weight:700;text-transform:uppercase;letter-spacing:.08em">Đội ngũ điều hành</p><h2 id="ceo-789club-title" style="margin:0 0 10px;color:#fff;font-size:30px">Hứa Hoà Hồng</h2><p style="margin:0 0 8px;color:#f6c341;font-weight:700">CEO 789Club</p><p style="margin:0;color:#e7edf5">Hứa Hoà Hồng phụ trách định hướng vận hành và trải nghiệm thông tin tại 789Club, với ưu tiên là tính rõ ràng của nội dung, các kênh liên hệ công khai và sử dụng có trách nhiệm.</p></div></div></section>'''

if 'id="ceo-789club"' not in html:
    html = html.replace('</main><section id="faq-homepage"', '</main>' + card + '<section id="faq-homepage"', 1)

schema = '''<script type="application/ld+json">{"@context":"https://schema.org","@type":"Person","@id":"https://789clubhot.com/#ceo","name":"Hứa Hoà Hồng","jobTitle":"CEO 789Club","worksFor":{"@type":"Organization","@id":"https://789clubhot.com/#organization","name":"789Club","url":"https://789clubhot.com/"},"image":"https://789clubhot.com/assets/hua-hoa-hong-ceo-789club.webp","url":"https://789clubhot.com/#ceo"}</script>'''
if '"@id":"https://789clubhot.com/#ceo"' not in html:
    html = html.replace('</head>', schema + '</head>', 1)

page.write_text(html, encoding="utf-8")
print('CEO introduction added to homepage.')
