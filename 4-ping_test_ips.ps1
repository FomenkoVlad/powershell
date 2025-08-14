$ipList = Get-Content -Path "ips.txt"
$goodIps = @()
$badIps = @()

foreach ($ip in $ipList) {
    $trimmedIp = $ip.Trim()
    if (-not $trimmedIp) { continue }

    Write-Host "Pinging $trimmedIp..." -NoNewline

    try {
        $pingRequest = Test-Connection -ComputerName $trimmedIp -Count 1 -Quiet

        if ($pingRequest) {
            Write-Host " [OK]" -ForegroundColor Green
            $goodIps += $trimmedIp
        } else {
            Write-Host " [FAIL]" -ForegroundColor Red
            $badIps += $trimmedIp
        }
    }
    catch {
        Write-Host " [ERROR]" -ForegroundColor DarkRed
        $badIps += $trimmedIp
    }
}

$goodIps | Out-File -FilePath "goodIP.txt" -Encoding utf8
$badIps | Out-File -FilePath "badIP.txt" -Encoding utf8

Write-Host "`nScan complete. Good IPs: $($goodIps.Count), Bad IPs: $($badIps.Count)"
