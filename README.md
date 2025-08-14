**Better to run all scripts from a single directory. Scripts use .txt files created by other scripts. Intended to be run from script 1 to 13 in ascending order.**

**Scripts:**

**1-upgraded_computers_list.ps1**

	The script queries Active Directory for all computer accounts, retrieves each computer’s name, 	OS, DNS hostname, and IPv4 address (if resolvable), and saves the following to files:

	computers.txt: List of computers with their name, OS, hostname, and IP address.

	dnshostname.txt: Unique DNS hostnames.

ips.txt: Unique IPv4 addresses.

**2-ping_test_dns.ps1**

	It pings each DNS hostname from dnshostname.txt, writes reachable hostnames to goodDNS.txt, unreachable ones to badDNS.txt, and summarizes the results.

**3-port_scan_dns.ps1**

	The script reads hostnames from goodDNS.txt, checks if ports 445, 3389, and 22 are open on each, and saves the results to port-scan-results_DNS.txt.

**4-ping_test_ips.ps1**

It pings each IP from ips.txt, writes reachable IPs to goodIP.txt, unreachable ones to badIP.txt, and prints a summary count.

**5-port_scan_ips.ps1**

	It scans each IP from goodIP.txt for open ports 445, 3389, and 22, then saves the list of open ports for each IP to port-scan-results.txt.

**6-check_Rights_On_DNS.ps1**

	Checks dangerous rights on goodDNS.txt and outputs the hostnames with rights to rightshigh_DNS. Requires Get-ADComputer.

**7-check_Rights_On_IPs.ps1**
	
	Checks dangerous rights on goodIP.txt and outputs the hostnames with rights to rightshigh_IPS.txt. Requires Get-ADComputer.

**8-.NET-test_dns_rights.ps1**

	Checks dangerous rights on goodDNS.txt and outputs the hostnames with rights to HighRightsDNS.txt. Uses .NET

**9-.NET-test_ip_rights.ps1**

	Checks dangerous rights on goodIP.txt and outputs the hostnames with rights to HighRightsIP.txt. Uses .NET

**10-DNS-SMB.ps1**
	
	Checks SMBs using goodDNS.txt and outputs results into two files.

**11-SMB-IP.ps1**
	
	Checks SMBs using goodIP.txt and outputs results into two files.

**12-calc-launch-dnshostname.ps1**

	Check goodDNS.txt and tries to launch a calculator process on each dnshostname from the list, using domain credentials. Outputs dnshostnames where succeeded into dnshostname_granted_calc.txt

**13-calc-launch-IP.ps1**

	Check goodIPs.txt and tries to launch a calculator process on each IP from the list, using domain credentials. Outputs IPs where succeeded into ip_granted_calc.txt
 

