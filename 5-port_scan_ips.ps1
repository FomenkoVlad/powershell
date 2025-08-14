$goodIPs = Get-Content -Path "goodIP.txt"
$portsToCheck = @(445, 3389, 22)
$output = @()

foreach ($ip in $goodIPs) {
    $ip = $ip.Trim()
    if (-not $ip) { continue }

    Write-Host "`nscanning $ip..." -ForegroundColor Cyan
    $openPorts = @()

    foreach ($port in $portsToCheck) {
        try {
            $tcpClient = New-Object System.Net.Sockets.TcpClient
            $async = $tcpClient.BeginConnect($ip, $port, $null, $null)
            $wait = $async.AsyncWaitHandle.WaitOne(1000, $false)

            if ($wait -and $tcpClient.Connected) {
                $tcpClient.EndConnect($async)
                $openPorts += $port
                Write-Host " Port $port open" -ForegroundColor Gray
            } else {
                Write-Host " Port $port closed" -ForegroundColor DarkGray
            }

            $tcpClient.Close()
        }
        catch {
            Write-Host " error checking port $port on $ip" -ForegroundColor Red
        }
    }

    $output += "$ip : Open Ports - $($openPorts -join ', ')"
}

$output | Out-File -FilePath "port-scan-results_IPs.txt" -Encoding utf8
Write-Host "`nPort Scan Complete. Results save to 'port-scan-results_IPs.txt'"
