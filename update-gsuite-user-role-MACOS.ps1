# Parameters
	#param (
	#	[parameter(mandatory=$true)][string]$p12keypath,
	#	[parameter(mandatory=$true)][string]$adminemail,
	#	[parameter(mandatory=$true)][string]$customerid,
	#	[parameter(mandatory=$true)][string]$domainname,
	#	[parameter(mandatory=$true)][string]$serviceaccountclientid,
	#	[parameter(mandatory=$true)][string]$appemail,
	#	[parameter(mandatory=$true)][string]$csvfilepath
	#)
	$p12keypath = "C:\Temp\myp12file.p12"
	$adminemail = "myadminemail@email.com"
	$customerid = "C1234566"
	$domainname = "mydomain.com"
	$serviceaccountclientid = Client ID
	$appemail = "myserviceaccount@mydomain.com"
	$csvfilepath = "C:\Temp\mycsvfilepath.csv"
	$gs-schemaname = "AppStream_Bytespeed"
# Modules
	$allmodules = get-module -listavailable
	if ($allmodules.name -notcontains "Configuration") {
		install-module -name 'Configuration'
	} else {
		import-module "Configuration"
	}
	if ($allmodules.name -notcontains "PSGSuite") {
		install-module -name 'PSGSuite'
	} else {
		import-module "PSGSuite"
	}
# Configuration G-Suite
	set-psgsuiteconfig -configname "GSuite" -p12keypath $p12keypath -appemail $appemail -adminemail $adminemail -domain $domainname -serviceaccountclientid $serviceaccountclientid -customerid $customerid
# Schema Modifications
	$userschemaexists = get-gsuserschema | where {$_.displayname -eq $gs-schemaname}
	if (-not $userschemaexists) {
		new-gsuserschema -schemaname $gs-schemaname -fields (add-gsuserschemafield -fieldname "FederationRole" -fieldtype STRING -readaccesstype ADMINS_AND_SELF),(add-gsuserschemafield -fieldname "SessionDuration" -fieldtype STRING -readaccesstype ADMINS_AND_SELF)
		$userschemaexists = get-gsuserschema | where {$_.displayname -eq $gs-schemaname}
	}
	if ($userschemaexists -and (-not (test-path $csvfilepath))) {
		$allgsuitegroups = get-gsgroup | select Name,Email,FederationRole,SessionDuration
		$allgsuitegroups | export-csv $csvfilepath -notypeinformation
		exit
	}
	if ($userschemaexists -and (test-path $csvfilepath)) {
		$csvfileentries = import-csv $csvfilepath | where {$_.FederationRole -ne $null}
		foreach ($entry in $csvfileentries) {
			$groupexists = get-gsgroup $entry.email
			if ($groupexists) {
				$groupmemberlist = get-gsgroupmemberlist $entry.email# -Role member
				if ($groupmemberlist) {
					foreach ($groupmember in $groupmemberlist) {
						update-gsuser $groupmember.email -confirm:$false -customschemas @{
							$userschemaexists.schemaname = @{
								"FederationRole" = $entry.FederationRole
								"SessionDuration" = $entry.SessionDuration
							}
						}# | out-null
					}
				}
				$groupmemberlist = $null
			}
			$groupexists = $null
		}
	}