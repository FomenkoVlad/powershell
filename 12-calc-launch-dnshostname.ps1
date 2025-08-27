# Set your credentials
$username = "YOURDOMAIN\\yourusername"   # Or just "yourusername" if local account
$password = "YourPassword!"

# Read hostnames from file
$hosts = Get-Content -Path "goodDNS.txt"
$granted = @()
$denied = @()

foreach ($dnsHost in $hosts) {
    $dnsHost = $dnsHost.Trim()
    if (-not $dnsHost) { continue }

    $cmd = "wmic /node:$dnsHost /user:$username /password:$password process call create `"calc.exe`""
    $output = cmd /c $cmd 2>&1

    if ($output -match "Access is denied" -or $output -match "Logon failure") {
        $denied += $dnsHost
    }
    elseif ($output -match "ReturnValue = 0") {
        $granted += $dnsHost
    }
}

$granted | Out-File -Encoding utf8 "dnshostname_granted_calc.txt"
$denied  | Out-File -Encoding utf8 "dnshostname_denied_calc.txt"

Write-Host "Done. Successes in dnshostname_granted_calc.txt, denied in dnshostname_denied_calc.txt"
