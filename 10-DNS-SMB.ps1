$dnsHosts = Get-Content -Path "goodDNS.txt"
$found = @()
$notfound = @()

foreach ($dnsHost in $dnsHosts) {
    $dnsHost = $dnsHost.Trim()
    if (-not $dnsHost) { continue }

    $output = net view \\$dnsHost 2>&1
    if ($output -match "Disk|IPC") {
        $shares = $output | Select-String "Disk|IPC"
        $shareNames = $shares -replace "^\s+", ""
        $found += "$dnsHost : $($shareNames -join ', ')"
    } else {
        $notfound += $dnsHost
    }
}

$found | Out-File -Encoding utf8 "SMB_DNS.txt"
$notfound | Out-File -Encoding utf8 "NO_SMB_DNS.txt"
Write-Host "Done. Results in SMB_DNS.txt and NO_SMB_DNS.txt"
