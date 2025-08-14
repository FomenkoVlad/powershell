$domainObj = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$PDC = $domainObj.PdcRoleOwner.Name
$DN = ([adsisearcher]"").distinguishedName
$computers = "LDAP://$PDC/$DN"

$searcher = New-Object DirectoryServices.DirectorySearcher($computers)
$searcher.Filter = "(&(objectCategory=computer)(objectClass=computer))"
$searcher.PropertiesToLoad.Add("name") | Out-Null
$searcher.PropertiesToLoad.Add("operatingSystem") | Out-Null
$searcher.PropertiesToLoad.Add("dnshostname") | Out-Null
$results = $searcher.FindAll()

$ipList = @()
$dnsList = @()
$computersOut = @()

$results | ForEach-Object {
    $entry = $_.Properties
    $hostname = $entry.dnshostname
    $ipAddress = "N/A"
    $sip = "N/A"
    
    try {
        $ipAddress = [System.Net.Dns]::GetHostAddresses($hostname) | Where-Object { $_.AddressFamily -eq "InterNetwork" } | Select-Object -First 1
        if ($ipAddress) {
            $sip = $ipAddress.IPAddressToString
            $ipList += $sip
        }
    } catch {
        $sip = "N/A"
    }
    
    if ($hostname) {
        $dnsList += $hostname
    }
    $computersOut += "Name: $($entry.name) | OS: $($entry.operatingsystem) | Hostname: $hostname | IP: $sip"
}

$computersOut | Out-File "computers.txt" -Encoding utf8
$dnsList | Sort-Object -Unique | Out-File "dnshostname.txt" -Encoding utf8
$ipList | Sort-Object -Unique | Out-File "ips.txt" -Encoding utf8
