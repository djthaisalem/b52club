param([string]$SiteDir = 'E:\2026\codex\baccarat\789clubhot')

$Utf8 = [Text.UTF8Encoding]::new($false)
$IndexFiles = @(
    'index.html',
    'gioi-thieu-789club.html',
    'huong-dan-dang-ky-789club.html',
    'huong-dan-dang-nhap.html',
    'tin-tuc.html'
)

Get-ChildItem -LiteralPath $SiteDir -Filter '*.html' -File | ForEach-Object {
    $html = [IO.File]::ReadAllText($_.FullName, [Text.Encoding]::UTF8)
    $robots = if ($_.Name -in $IndexFiles) {
        '<meta name="robots" content="index, follow, max-snippet:-1, max-video-preview:-1, max-image-preview:large">'
    } else {
        '<meta name="robots" content="noindex, follow, max-snippet:-1, max-video-preview:-1, max-image-preview:large">'
    }
    if ($html -match '(?is)<meta\s+name=["'']robots["''][^>]*>') {
        $html = [regex]::Replace($html, '(?is)<meta\s+name=["'']robots["''][^>]*>', $robots, 1)
    } else {
        $html = $html -replace '</title>', ('</title>' + $robots)
    }
    [IO.File]::WriteAllText($_.FullName, $html, $Utf8)
}

$domain = 'https://789clubhot.com/'
$lastmod = '2026-08-02'
$urls = foreach ($file in $IndexFiles) {
    $loc = if ($file -eq 'index.html') { $domain } else { $domain + $file }
    "  <url><loc>$loc</loc><lastmod>$lastmod</lastmod></url>"
}
$sitemap = '<?xml version="1.0" encoding="UTF-8"?>' + "`r`n" +
    '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' + "`r`n" +
    ($urls -join "`r`n") + "`r`n" +
    '</urlset>'
[IO.File]::WriteAllText((Join-Path $SiteDir 'sitemap.xml'), $sitemap, $Utf8)

"Đã bật index $($IndexFiles.Count) trang và đặt noindex, follow cho các trang còn lại."
