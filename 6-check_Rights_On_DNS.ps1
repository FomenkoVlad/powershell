Import-Module ActiveDirectory

$user = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
$hostnames = Get-Content -Path "goodDNS.txt"
$dangerousRights = @("GenericAll", "WriteDACL", "WriteOwner", "WriteProperty")
$highRights = @()
$lowRights = @()

foreach ($hostname in $hostnames) {
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
                        $highRights += $hostname
                        $hasDangerous = $true
                        break
                    }
                }
                if ($hasDangerous) { break }
            }
        }
        if (-not $hasDangerous) {
            $lowRights += $hostname
        }
    }
}

$highRights | Sort-Object -Unique | Out-File -Encoding utf8 "rightshigh_DNS.txt"
$lowRights  | Sort-Object -Unique | Out-File -Encoding utf8 "lowrights_DNS.txt"
Write-Host "Done. Dangerous rights in rightshigh_DNS.txt, others in lowrights_DNS.txt"
