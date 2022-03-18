<#
.synopsis
   <<synopsis goes here>>
.Description
  <<Description goes here>>
.Notes
  ScriptName  : PatchingListgenerater.PS1
  Requires    : Powershell Version 5.0
  Author      : Jithendra Kudikala
  EMAIL       : jithendra.kudikala@gmail.com
  Version     : 1.1 Script will get poweredoff machines from XenDesktop Site and power them on in batches from vCenter
.Parameter
   None
 .Example
   None
#>

add-pssnapin citrix*
add-pssnapin vmware*
$currentdate = Get-Date -format yyyy-MMM
$cred = Get-Credential
$importdata = Get-Content "Enter .txt location"
foreach($data in $importdata)
{
    $DDC = $data.Split(",").[0]
    $VIServer = $data.Split(",").[1]
    $poweroffmachines = (get-brokermachine -adminaddress $ddc -maxrecordcount 9999 | Where-Object {($_.powerstate -eq "OFF") -and ($_.InmaintenanceMode -eq $false) -and ($_.hostedmachinename -ne $null) -and ($_.poweractionpending -eq $false)}).hostedmachinename
    connect-viserver $VIServer -credential $cred
        for($i=0;$i -lt $poweroffmachines.count;$i+=100)
        {
            $j = $i+100
            $batch = $poweroffmachines[$i..$j]
            start-vm -vm $batch -confirm:$false
            Sleep 60
        }
        Disconnect-viserver $VIServer -confirm:$false
}
