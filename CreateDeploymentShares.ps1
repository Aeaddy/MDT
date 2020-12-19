$SYSDR = $env:SystemDrive
$FILEPATH="$SYSDR\temp"
New-Item -ItemType Directory $FILEPATH

Configuration CreateShares
{ 
 
  param(
    [Parameter(Mandatory=$true)]
    [String[]]$Servers
  )
 
  Node $Servers
  { 
   

  Script MDTDeploymentShareDirectory
{
    SetScript = { new-item -ItemType Directory "C:\DeploymentShare" }

    TestScript = { test-path "C:\DeploymentShare" }

    GetScript = { dir C:\ }

}


  Script MDTDeploymentShareSMBSHARE
{
    SetScript = { New-SMBShare -Name "MDTDeploymentShare" -Path "C:\DeploymentShare" }

    TestScript = { test-path \\localhost\MDTDeploymentShare }

    GetScript = { Get-SMBShare }
}

    }
}

#Commands to execute:
CreateShares -Servers localhost -OutputPath $FILEPATH

Start-DscConfiguration -Path $FILEPATH -wait -Verbose -Force -ErrorAction Stop 

Remove-Item $FILEPATH -Recurse 

