$targetIPs = Get-Content -Path "goodIP.txt"
$found = @()
$notfound = @()

foreach ($targetIP in $targetIPs) {
    $targetIP = $targetIP.Trim()
    if (-not $targetIP) { continue }

    $output = net view \\$targetIP 2>&1
    if ($output -match "Disk|IPC") {
        $shares = $output | Select-String "Disk|IPC"
        $shareNames = $shares -replace "^\s+", ""
        $found += "$targetIP : $($shareNames -join ', ')"
    } else {
        $notfound += $targetIP
    }
}

$found | Out-File -Encoding utf8 "SMB_IP.txt"
$notfound | Out-File -Encoding utf8 "NO_SMB_IP.txt"
Write-Host "Done. Results in SMB_IP.txt and NO_SMB_IP.txt"
