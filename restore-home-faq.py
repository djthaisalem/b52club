from pathlib import Path
import re

page = Path(r"E:\2026\codex\baccarat\789clubhot\index.html")
html = page.read_text(encoding="utf-8")

# Remove the FAQ that was trapped inside the scrolling introduction panel.
html = re.sub(
    r'<h2>Câu hỏi thường gặp về 789Club</h2>.*?</p></article>',
    '</article>',
    html,
    count=1,
    flags=re.S,
)

faq = '''<section id="faq-homepage" aria-labelledby="faq-homepage-title" style="padding:48px 20px;background:#101824;color:#fff"><div style="max-width:1120px;margin:auto"><h2 id="faq-homepage-title" style="margin:0 0 24px;text-align:center;color:#ffc31a;font-size:clamp(26px,3vw,38px)">Câu hỏi thường gặp về 789Club</h2><div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(245px,1fr));gap:18px"><article style="padding:22px;border:1px solid #e5aa18;border-radius:12px;background:#182332"><h3 style="margin-top:0;color:#fff">Website chính thức của 789Club là gì?</h3><p style="margin-bottom:0;color:#edf2f7">Địa chỉ được công bố là <a href="index.html" style="color:#ffd45a">789clubhot.com</a>. Hãy kiểm tra kỹ tên miền trước khi đăng nhập hoặc tải ứng dụng.</p></article><article style="padding:22px;border:1px solid #e5aa18;border-radius:12px;background:#182332"><h3 style="margin-top:0;color:#fff">Làm thế nào để liên hệ 789Club?</h3><p style="margin-bottom:0;color:#edf2f7">Hotline 099.58.57.600 và email 789clubhotorg@gmail.com là các kênh liên hệ công khai để đối chiếu thông tin.</p></article><article style="padding:22px;border:1px solid #e5aa18;border-radius:12px;background:#182332"><h3 style="margin-top:0;color:#fff">789Club có những chủ đề nào?</h3><p style="margin-bottom:0;color:#edf2f7">Trang chủ tổng hợp game, hướng dẫn tài khoản, ưu đãi và bài viết kiến thức; mỗi mục đều liên kết đến trang chi tiết tương ứng.</p></article></div></div></section>'''

if 'id="faq-homepage"' not in html:
    html = html.replace('</main>', '</main>' + faq, 1)

schema = '''<script type="application/ld+json">{"@context":"https://schema.org","@type":"FAQPage","mainEntity":[{"@type":"Question","name":"Website chính thức của 789Club là gì?","acceptedAnswer":{"@type":"Answer","text":"Địa chỉ được công bố là https://789clubhot.com/. Hãy kiểm tra kỹ tên miền trước khi đăng nhập hoặc tải ứng dụng."}},{"@type":"Question","name":"Làm thế nào để liên hệ 789Club?","acceptedAnswer":{"@type":"Answer","text":"Hotline 099.58.57.600 và email 789clubhotorg@gmail.com là các kênh liên hệ công khai để đối chiếu thông tin."}},{"@type":"Question","name":"789Club có những chủ đề nào?","acceptedAnswer":{"@type":"Answer","text":"Trang chủ tổng hợp game, hướng dẫn tài khoản, ưu đãi và bài viết kiến thức; mỗi mục đều liên kết đến trang chi tiết tương ứng."}}]}</script>'''
if '"@type":"FAQPage"' not in html:
    html = html.replace('</head>', schema + '</head>', 1)

page.write_text(html, encoding="utf-8")
print('Homepage FAQ restored.')
