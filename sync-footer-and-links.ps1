param([string]$SiteDir = 'E:\2026\codex\baccarat\789clubhot')

$Utf8 = [Text.UTF8Encoding]::new($false)
$mapUrl = 'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d5601.32992742192!2d107.9786551763972!3d13.957030892506161!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x316c21c3a2f2fb23%3A0xf13e56df85de1848!2zMTc5IFRy4bqnbiBOaOG6rXQgRHXhuq10LCBEacOqbiBI4buTbmcsIEdpYSBMYWksIFZp4buHdCBOYW0!5e1!3m2!1svi!2s!4v1785721828916!5m2!1svi!2s'
$mapLink = 'https://www.google.com/maps/search/?api=1&query=179%20Tr%E1%BA%A7n%20Nh%E1%BA%ADt%20Du%E1%BA%ADt%2C%20Di%C3%AAn%20H%E1%BB%93ng%2C%20Gia%20Lai%2C%20Vi%E1%BB%87t%20Nam'
$address = 'Địa chỉ: 179 Trần Nhật Duật, Diên Hồng, Gia Lai, Việt Nam'
$mapBlock = '<div class="footer-map" style="width:100%;margin:22px 0 0;padding:0"><iframe src="' + $mapUrl + '" width="1920" height="600" style="border:0;width:100%;max-width:100%;height:clamp(220px,31.25vw,600px);display:block" allowfullscreen="" loading="lazy" referrerpolicy="strict-origin-when-cross-origin" title="Bản đồ địa chỉ 789Club"></iframe></div>'
$games = @(
    'xoc-dia-truc-tuyen.html',
    'tai-xiu-doi-thuong.html',
    'ban-ca-doi-thuong.html',
    'no-hu-doi-thuong.html',
    'rong-ho-truc-tuyen.html',
    'dua-ngua-789club.html'
)

$updated = 0
Get-ChildItem -LiteralPath $SiteDir -Filter '*.html' -File | ForEach-Object {
    $html = [IO.File]::ReadAllText($_.FullName, [Text.Encoding]::UTF8)
    $original = $html

    foreach ($game in $games) {
        $html = $html.Replace('href="' + $game + '" target="_blank" rel="nofollow noopener"', 'href="' + $game + '"')
    }

    $footerMatch = [regex]::Match($html, '(?s)<footer id="footer".*?</footer>')
    if (-not $footerMatch.Success) { throw "Không tìm thấy footer trong $($_.Name)" }
    $footer = $footerMatch.Value
    $locationPattern = '(?is)<a class="ux-menu-link__link flex" href="#"\s*><i class="ux-menu-link__icon text-center icon-map-pin-fill"\s*></i><span class="ux-menu-link__text">.*?(?:Dia chi|Địa chỉ).*?</span></a>'
    $locationReplacement = '<a class="ux-menu-link__link flex" href="' + $mapLink + '" target="_blank" rel="noopener" aria-label="Mở vị trí 789Club trên Google Maps"><i class="ux-menu-link__icon text-center icon-map-pin-fill" ></i><span class="ux-menu-link__text">' + $address + '</span></a>'
    $footer = [regex]::Replace($footer, $locationPattern, $locationReplacement, 1)

    $footer = [regex]::Replace($footer, '(?s)<div class="footer-map".*?</div>', '')
    $keywordPattern = '(?s)(Từ khóa được tìm kiếm nhiều nhất:.*?</p></div></div></div>)(<div class="text-center"><div class="is-divider)'
    if ($footer -notmatch $keywordPattern) { throw "Không tìm thấy cụm từ khóa footer trong $($_.Name)" }
    $footer = [regex]::Replace($footer, $keywordPattern, ('$1' + $mapBlock + '$2'), 1)

    $html = $html.Replace($footerMatch.Value, $footer)
    if ($html -ne $original) {
        [IO.File]::WriteAllText($_.FullName, $html, $Utf8)
        $updated++
    }
}

"Đã đồng bộ liên kết game và footer cho $updated trang."
