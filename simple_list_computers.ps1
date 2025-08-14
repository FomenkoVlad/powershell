$domainObj = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$PDC = $domainObj.PdcRoleOwner.Name
$DN = ([adsisearcher]"").SearchRoot.Path.Split("/")[2]
$computers = "LDAP://$PDC/$DN"

$searcher = New-Object DirectoryServices.DirectorySearcher($computers)
$searcher.Filter = "(&(objectCategory=computer)(objectClass=computer))"
$searcher.PropertiesToLoad.Add("name") | Out-Null
$searcher.PropertiesToLoad.Add("operatingsystem") | Out-Null
$searcher.PropertiesToLoad.Add("dnshostname") | Out-Null
$results = $searcher.FindAll()

$results | ForEach-Object {
    $entry = $_.Properties
    $hostName = $entry.dnshostname

    try {
        $ipAddress = [System.Net.Dns]::GetHostEntry($hostName) | Select-Object -ExpandProperty AddressList | Where-Object { $_.AddressFamily -eq 'InterNetwork' } | Select-Object -First 1
        $ipAddressString = $ipAddress.IPAddressToString
    }
    catch {
        $ipAddressString = "unable to resolve"
    }

    [PSCustomObject]@{
        Name = $entry.name
        OperatingSystem = $entry.operatingsystem
        DNSHostname = $hostName
        IPAddress = $ipAddressString
    }
}
