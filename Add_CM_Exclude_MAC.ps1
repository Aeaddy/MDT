[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true,Position=0)]
    $MACS
    )

$key = "hklm:\SOFTWARE\Microsoft\SMS\Components\SMS_DISCOVERY_DATA_MANAGER"

$OLDMACS=(Get-ItemProperty $key).ExcludeMACAddress
$NEWMACS = $OLDMACS + $MACS
if ($OLDMACS -contains $MACS){
Write-Output "This entry already exists"
}ELSE{
Set-itemProperty $key ExcludeMACAddress -value $NEWMACS -type MultiString
}