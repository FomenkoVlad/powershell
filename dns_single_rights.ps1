$hostname = "computer.domain.dnshostname"

$searcher = New-Object DirectoryServices.DirectorySearcher
$searcher.Filter = "(&(objectCategory=computer)(dNSHostName=$hostname))"
$result = $searcher.FindOne()

if ($result) {
    $dn = $result.Properties.distinguishedname[0]
    $adObject = [ADSI]"LDAP://$dn"
    $acl = $adObject.psbase.ObjectSecurity.Access
    $userSid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value

    $myAces = $acl | Where-Object { $_.IdentityReference.Value -eq $userSid }
    if ($myAces) {
        Write-Host "ACE(s) found for your user on ${hostname}:"
        $myAces | Select-Object IdentityReference, ActiveDirectoryRights, AccessControlType
    } else {
        Write-Host "No ACEs found for your user on ${hostname}. This means you have no direct rights."
    }
} else {
    Write-Host "No AD computer object found for ${hostname} (check spelling or AD membership)."
}

