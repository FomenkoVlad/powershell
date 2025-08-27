$userSid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
$dangerousRights = @('GenericAll', 'WriteDACL', 'WriteOwner', 'WriteProperty')
$dnsList = Get-Content -Path "goodDNS.txt"
$highRights = @()
$lowRights = @()

foreach ($hostname in $dnsList) {
    $hostname = $hostname.Trim()
    if (-not $hostname) { continue }

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
                        $highRights += $hostname
                        $hasDangerous = $true
                        break
                    }
                }
                if ($hasDangerous) { break }
            }
        }
        if (-not $hasDangerous) { $lowRights += $hostname }
    }
}

$highRights | Sort-Object -Unique | Out-File -Encoding utf8 "HighRightsDNS.txt"
$lowRights  | Sort-Object -Unique | Out-File -Encoding utf8 "LowRightsDNS.txt"
Write-Host "Done. High rights in HighRightsDNS.txt, low in LowRightsDNS.txt"
