# Set your credentials
$username = "YOURDOMAIN\\yourusername"   # Or just "yourusername" if local account
$password = "YourPassword!"

# Read IPs from file
$ips = Get-Content -Path "goodIP.txt"
$granted = @()
$denied = @()

foreach ($targetIP in $ips) {
    $targetIP = $targetIP.Trim()
    if (-not $targetIP) { continue }

    $cmd = "wmic /node:$targetIP /user:$username /password:$password process call create `"calc.exe`""
    $output = cmd /c $cmd 2>&1

    if ($output -match "Access is denied" -or $output -match "Logon failure") {
        $denied += $targetIP
    }
    elseif ($output -match "ReturnValue = 0") {
        $granted += $targetIP
    }
}

$granted | Out-File -Encoding utf8 "ip_granted_calc.txt"
$denied  | Out-File -Encoding utf8 "ip_denied_calc.txt"

Write-Host "Done. Successes in ip_granted_calc.txt, denied in ip_denied_calc.txt"
