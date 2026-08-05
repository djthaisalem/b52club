param(
    [string]$SourceDir = 'E:\sun\2026\789club',
    [string]$SiteDir = 'E:\2026\codex\baccarat\789clubhot'
)

$ErrorActionPreference = 'Stop'
$Utf8 = New-Object System.Text.UTF8Encoding($false, $true)
$OutputUtf8 = New-Object System.Text.UTF8Encoding($false)
$TargetDomain = 'https://789clubhot.com'

function Get-CanonicalSlug([string]$Html) {
    $canonical = [regex]::Match($Html, '<link rel="canonical" href="([^"]+)"').Groups[1].Value
    if (-not $canonical) { throw 'Missing canonical URL.' }
    return ([Uri]$canonical).AbsolutePath.Trim('/')
}

function Get-PageTitle([string]$Slug) {
    $words = ($Slug -split '-') | ForEach-Object {
        if ($_.Length -le 3) { $_.ToUpperInvariant() } else { $_.Substring(0, 1).ToUpperInvariant() + $_.Substring(1) }
    }
    return "789Club | $($words -join ' ')"
}

$documents = Get-ChildItem -LiteralPath $SourceDir -Filter '*.txt' -File |
    Where-Object Name -ne 'home.txt'

$pagesBySlug = @{}
foreach ($document in $documents) {
    $html = [IO.File]::ReadAllText($document.FullName, $Utf8)
    $slug = Get-CanonicalSlug $html
    # The specifically named birthday-promotion document is the authoritative one for this duplicate URL.
    if (-not $pagesBySlug.ContainsKey($slug) -or $document.Name -like '*sinh nhat*') {
        $pagesBySlug[$slug] = [pscustomobject]@{ Document = $document; Html = $html }
    }
}

$urlMap = @{ "$TargetDomain/" = 'index.html'; "$TargetDomain/vi-vn/" = 'index.html' }
foreach ($slug in $pagesBySlug.Keys) { $urlMap["$TargetDomain/$slug/"] = "$slug.html" }

$imageUrls = [System.Collections.Generic.HashSet[string]]::new()
foreach ($page in $pagesBySlug.Values) {
    foreach ($match in [regex]::Matches($page.Html, 'https?://[^\s"''<>]+/wp-content/uploads/[^\s"''<>]+\.(?:avif|gif|jpe?g|png|svg|webp)(?:\?[^\s"''<>]+)?')) {
        [void]$imageUrls.Add($match.Value)
    }
}

foreach ($url in $imageUrls) {
    $uri = [Uri]$url
    $relative = $uri.AbsolutePath.TrimStart('/')
    $target = Join-Path $SiteDir ('assets\' + $relative.Replace('/', '\'))
    if (-not (Test-Path -LiteralPath $target)) {
        New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force | Out-Null
        Invoke-WebRequest -Uri $url -OutFile $target -TimeoutSec 30
    }
}

foreach ($entry in $pagesBySlug.GetEnumerator()) {
    $slug = $entry.Key
    $html = $entry.Value.Html
    $title = Get-PageTitle $slug
    $description = "Thong tin $($slug -replace '-', ' ') tai 789Club. Tim hieu noi dung, huong dan va luu y can thiet truoc khi tham gia."
    $canonical = "$TargetDomain/$slug.html"

    $html = [regex]::Replace($html, 'https?://[^/]+(/wp-content/uploads/[^\s"''<>?]+)(?:\?[^\s"''<>]*)?', 'assets$1')
    foreach ($mapping in $urlMap.GetEnumerator()) { $html = $html.Replace($mapping.Key, $mapping.Value) }
    $html = [regex]::Replace($html, 'https?://(?:www\.)?(?:789clubvn10\.com|789club24\.com|789clubhot\.(?:org|info))', $TargetDomain)
    $html = [regex]::Replace($html, '(?s)<title>.*?</title>', "<title>$title</title>", 1)
    $html = [regex]::Replace($html, '<meta name="description"[^>]*>', "<meta name=`"description`" content=`"$description`" />", 1)
    $html = [regex]::Replace($html, '<link rel="canonical"[^>]*>', "<link rel=`"canonical`" href=`"$canonical`" />", 1)
    $html = [regex]::Replace($html, '<meta property="og:url"[^>]*>', "<meta property=`"og:url`" content=`"$canonical`" />", 1)
    $html = [regex]::Replace($html, '<meta property="og:title"[^>]*>', "<meta property=`"og:title`" content=`"$title`" />", 1)
    $html = [regex]::Replace($html, '<meta property="og:description"[^>]*>', "<meta property=`"og:description`" content=`"$description`" />", 1)
    $html = [regex]::Replace($html, '<meta name="twitter:title"[^>]*>', "<meta name=`"twitter:title`" content=`"$title`" />", 1)
    $html = [regex]::Replace($html, '<meta name="twitter:description"[^>]*>', "<meta name=`"twitter:description`" content=`"$description`" />", 1)
    $oldDomain = '789clubhot' + '.org'
    $html = $html.Replace('0987898767', '099.58.57.600').Replace($oldDomain, '789clubhot.com')
    $html = [regex]::Replace($html, 'Email:\s*<span class="__cf_email__"[^>]*>.*?</span>', 'Email: 789clubhotorg@gmail.com', 1)
    [IO.File]::WriteAllText((Join-Path $SiteDir "$slug.html"), $html, $OutputUtf8)
}

Write-Output "Generated $($pagesBySlug.Count) static subpages and collected $($imageUrls.Count) image URLs."
