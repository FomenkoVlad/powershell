Import-Module ActiveDirectory

$user = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
$ips = Get-Content -Path "goodIP.txt"
$dangerousRights = @("GenericAll", "WriteDACL", "WriteOwner", "WriteProperty")
$highRights = @()
$lowRights = @()

foreach ($ip in $ips) {
    try {
        $hostname = [System.Net.Dns]::GetHostEntry($ip).HostName
        $computer = Get-ADComputer -Filter { DnsHostName -eq $hostname } -Properties distinguishedName
        $hasDangerous = $false

        if ($computer) {
            $dn = $computer.DistinguishedName
            $adObject = [ADSI]"LDAP://$dn"
            $acl = $adObject.psbase.ObjectSecurity.Access

            foreach ($ace in $acl) {
                if ($ace.IdentityReference.Value -eq $user) {
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
            if (-not $hasDangerous) {
                $lowRights += $ip
            }
        }
    } catch {
        Write-Host "Failed to resolve or query $ip"
    }
}

$highRights | Sort-Object -Unique | Out-File -Encoding utf8 "rightshigh_IPS.txt"
$lowRights  | Sort-Object -Unique | Out-File -Encoding utf8 "lowrights_IPS.txt"
Write-Host "Done. Dangerous rights in rightshigh_IPS.txt, others in lowrights_IPS.txt"
