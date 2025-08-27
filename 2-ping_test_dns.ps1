$DNSList = Get-Content -Path "dnshostname.txt"
$goodDNS = @()
$badDNS = @()

foreach ($dns in $DNSList) {
    $dns = $dns.Trim()
    if (-not $dns) { continue }

    Write-Host "Pinging $dns..." -NoNewline

    try {
        $pingRequest = Test-Connection -ComputerName $dns -Count 1 -Quiet

        if ($pingRequest) {
            Write-Host " [OK]" -ForegroundColor Green
            $goodDNS += $dns
        } else {
            Write-Host " [FAIL]" -ForegroundColor Red
            $badDNS += $dns
        }
    }
    catch {
        Write-Host " [ERROR]" -ForegroundColor DarkRed
        $badDNS += $dns
    }
}

$goodDNS | Out-File -FilePath "goodDNS.txt" -Encoding utf8
$badDNS | Out-File -FilePath "badDNS.txt" -Encoding utf8

Write-Host "`nScan complete. Good DNS: $($goodDNS.Count), Bad IPs: $($badDNS.Count)"
