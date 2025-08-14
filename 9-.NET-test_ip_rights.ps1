$userSid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
$dangerousRights = @('GenericAll', 'WriteDACL', 'WriteOwner', 'WriteProperty')
$ipList = Get-Content -Path "goodIP.txt"
$highRights = @()
$lowRights = @()

foreach ($ip in $ipList) {
    $ip = $ip.Trim()
    if (-not $ip) { continue }

    try {
        $hostname = [System.Net.Dns]::GetHostEntry($ip).HostName
    } catch {
        continue
    }

    $searcher = New-Object DirectoryServices.DirectorySearcher
    $searcher.Filter = "(&(objectCategory=computer)(dNSHostName=$hostname))"
    $result = $searcher.FindOne()

    $hasDangerous = $false
    if ($result) {
        $dn = $result.Properties.distinguishedname[0]
        $adObject = [ADSI]"LDAP://$dn"
        $acl = $adObject.psbase.ObjectSecurity.Access

        foreach ($ace in $acl) {
            if ($ace.IdentityReference.Value -eq $userSid) {
                foreach ($right in $dangerousRights) {
                    if ($ace.ActiveDirectoryRights.ToString().Contains($right)) {
                        $highRights += $ip
                        $hasDangerous = $true
                        break
                    }
                }
                if ($hasDangerous) { break }
            }
        }
        if (-not $hasDangerous) { $lowRights += $ip }
    }
}

$highRights | Sort-Object -Unique | Out-File -Encoding utf8 "HighRightsIP.txt"
$lowRights  | Sort-Object -Unique | Out-File -Encoding utf8 "LowRightsIP.txt"
Write-Host "Done. High rights in HighRightsIP.txt, low in LowRightsIP.txt"
