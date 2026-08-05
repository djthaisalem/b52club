param([string]$SiteDir = 'E:\2026\codex\baccarat\789clubhot')

$Utf8 = New-Object System.Text.UTF8Encoding($false, $true)
$OutputUtf8 = New-Object System.Text.UTF8Encoding($false)

function Get-ContentType([string]$Slug) {
    if ($Slug -match 'khuyen-mai|hoan-tra|sinh-nhat') { return 'ưu đãi và điều kiện áp dụng' }
    if ($Slug -match 'huong-dan|dang-nhap|dang-ky|nap-tien|rut-tien|tai-app') { return 'hướng dẫn sử dụng' }
    if ($Slug -match 'tin-tuc|cach-|meo-|kinh-nghiem|bi-quyet|thu-thuat') { return 'kiến thức và lưu ý' }
    return 'giải trí trực tuyến'
}

$Topics = @{
    'ban-ca-doi-thuong' = 'Bắn Cá đổi thưởng'; 'bi-quyet-choi-tai-xiu-md5' = 'bí quyết chơi Tài Xỉu MD5'; 'cach-bat-cau-rong-ho-chuan-xac' = 'cách theo dõi Rồng Hổ'; 'cach-bat-cau-xoc-dia-chuan' = 'hướng dẫn tham khảo Xóc Đĩa'; 'cach-choi-bai-cao-thang-nhanh' = 'cách chơi Bài Cào'; 'cach-choi-bau-cua-luon-thang' = 'cách chơi Bầu Cua'; 'cach-choi-xi-ngau-online-de-trung' = 'kiến thức Xì Ngầu online'; 'cach-choi-xo-so-sieu-toc' = 'tìm hiểu Xổ Số Siêu Tốc'; 'cach-quay-no-hu-chuan-xac' = 'cách tìm hiểu game Nổ Hũ'; 'cach-soi-cau-tai-xiu' = 'lưu ý khi theo dõi Tài Xỉu'; 'dua-ngua-789club' = 'Đua ngựa 789Club'; 'gioi-thieu-789club' = 'giới thiệu 789Club'; 'hoan-tra' = 'hoàn trả'; 'huong-dan-dang-ky-789club' = 'hướng dẫn đăng ký 789Club'; 'huong-dan-dang-nhap' = 'hướng dẫn đăng nhập 789Club'; 'huong-dan-nap-tien-789club' = 'hướng dẫn nạp tiền 789Club'; 'huong-dan-rut-tien' = 'hướng dẫn rút tiền 789Club'; 'huong-dan-tai-app-789club' = 'hướng dẫn tải app 789Club'; 'khuyen-mai-dang-ky' = 'khuyến mãi đăng ký'; 'khuyen-mai-gioi-thieu' = 'khuyến mãi giới thiệu'; 'khuyen-mai-nap-dau' = 'khuyến mãi nạp đầu'; 'khuyen-mai-nap-lai-lan-2' = 'khuyến mãi nạp lại lần 2'; 'kinh-nghiem-ban-ca-an-tien' = 'kinh nghiệm tìm hiểu Bắn Cá'; 'kinh-nghiem-kiem-tien-tu-nha-cai' = 'quản lý trải nghiệm giải trí'; 'meo-choi-baccarat-de-thang' = 'tìm hiểu Baccarat cho người mới'; 'meo-choi-tai-xiu-chuan-xac' = 'mẹo tiếp cận Tài Xỉu có trách nhiệm'; 'meo-thang-baccarat' = 'lưu ý khi trải nghiệm Baccarat'; 'meo-tim-game-no-hu' = 'cách chọn game Nổ Hũ'; 'no-hu-doi-thuong' = 'Nổ Hũ đổi thưởng'; 'rong-ho-truc-tuyen' = 'Rồng Hổ trực tuyến'; 'sinh-nhat' = 'khuyến mãi sinh nhật'; 'tai-xiu-doi-thuong' = 'Tài Xỉu đổi thưởng'; 'thu-thuat-ca-do-bong-da' = 'kiến thức cơ bản về thể thao'; 'xoc-dia-truc-tuyen' = 'Xóc Đĩa trực tuyến'
}

Get-ChildItem -LiteralPath $SiteDir -Filter '*.html' -File | Where-Object { $_.Name -notin @('index.html', 'tin-tuc.html') } | ForEach-Object {
    $file = $_
    $slug = [IO.Path]::GetFileNameWithoutExtension($file.Name)
    $topic = if ($Topics.ContainsKey($slug)) { $Topics[$slug] } else { $slug -replace '-', ' ' }
    $type = Get-ContentType $slug
    $html = [IO.File]::ReadAllText($file.FullName, $Utf8)
    $main = [regex]::Match($html, '(?s)<main id="main".*?</main>')
    if (-not $main.Success) { throw "Missing main content in $($file.Name)" }
    $figures = [regex]::Matches($main.Value, '(?s)<figure .*?</figure>') | Select-Object -First 2 | ForEach-Object {
        [regex]::Replace($_.Value, 'alt="[^"]*"', "alt=`"Hinh minh hoa $topic tai 789Club`"")
    }
    $figureOne = if ($figures.Count -gt 0) { $figures[0] } else { '' }
    $figureTwo = if ($figures.Count -gt 1) { $figures[1] } else { '' }
    $title = "789Club | $topic"
    $canonical = "https://789clubhot.com/$slug.html"
    $body = @"
<main id="main" class="site-main">
  <section class="section" aria-labelledby="$slug-title">
    <div class="section-content relative"><div class="row row-large"><div class="col small-12 large-10 large-offset-1"><div class="col-inner home-content">
      <article class="789club-editorial">
        <header><h1 id="$slug-title">$topic tại 789Club</h1><p>Trang này tổng hợp thông tin về <strong>$topic</strong> theo hướng rõ ràng, dễ đọc và có trách nhiệm. Nội dung được biên soạn cho người dùng muốn tìm hiểu 789Club trước khi lựa chọn cách sử dụng phù hợp.</p></header>
        <h2>Thông tin cần biết</h2>
        <p>Chủ đề $topic thuộc nhóm $type tại 789Club. Người dùng nên xem kỹ hướng dẫn, điều khoản và các thông báo hiển thị trên hệ thống trước khi thực hiện bất kỳ thao tác nào. Thông tin trên trang có mục đích tham khảo, không thay thế cho quyết định cá nhân.</p>
        $figureOne
        <h2>Cách tiếp cận chủ động</h2>
        <p>Một trải nghiệm tốt bắt đầu từ việc hiểu đúng quy tắc. Hãy truy cập đúng địa chỉ 789clubhot.com, kiểm tra tên miền, bảo mật thông tin đăng nhập và không chia sẻ mã xác nhận. Khi cần hỗ trợ, sử dụng hotline 099.58.57.600 hoặc email 789clubhotorg@gmail.com.</p>
        <h3>Những điểm cần kiểm tra</h3>
        <p>Trước khi bắt đầu với $topic, hãy xác nhận thông tin tài khoản, cách vận hành của tính năng, giới hạn áp dụng và các điều kiện liên quan. Nếu có nội dung chưa rõ, hãy tạm dừng thao tác để đối chiếu thông tin từ kênh hỗ trợ công khai.</p>
        $figureTwo
        <h2>Sử dụng 789Club có trách nhiệm</h2>
        <p>789Club khuyến khích người dùng quản lý thời gian và ngân sách cá nhân. Không vay mượn, không sử dụng chi phí thiết yếu và nên nghỉ ngơi khi cảm thấy không thoải mái. Người chưa đủ tuổi theo quy định không nên truy cập các dịch vụ có yếu tố đặt cược.</p>
        <h2>Câu hỏi thường gặp</h2>
        <h3>Tìm thông tin $topic ở đâu?</h3><p>Bạn có thể bắt đầu từ menu chính hoặc các liên kết nội bộ trên 789clubhot.com. Các trang được sắp xếp theo chủ đề để dễ tìm và dễ đối chiếu.</p>
        <h3>Liên hệ 789Club bằng cách nào?</h3><p>Hotline 099.58.57.600 và email 789clubhotorg@gmail.com là các kênh liên hệ công khai. Địa chỉ: 179 Trần Nhật Duật, Diên Hồng, Gia Lai, Việt Nam.</p>
      </article>
    </div></div></div></div>
  </section>
</main>
"@
    $html = $html.Replace($main.Value, $body)
    $html = [regex]::Replace($html, '(?s)<script type="application/ld\+json">\{"@context":"https://schema.org","@type":"WebPage".*?</script>', '')
    $schema = "{`"@context`":`"https://schema.org`",`"@type`":`"WebPage`",`"@id`":`"$canonical#webpage`",`"url`":`"$canonical`",`"name`":`"$title`",`"description`":`"Thông tin $topic tại 789Club.`",`"inLanguage`":`"vi`",`"publisher`":{`"@type`":`"Organization`",`"name`":`"789Club`",`"url`":`"https://789clubhot.com/`"}}"
    $html = $html -replace '</head>', "<script type=`"application/ld+json`">$schema</script></head>"
    [IO.File]::WriteAllText($file.FullName, $html, $OutputUtf8)
}

Write-Output 'Rewrote all subpage editorial bodies and added WebPage schema.'
