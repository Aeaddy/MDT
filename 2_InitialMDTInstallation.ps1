Configuration InstallMDT   
{ 
 
  param(
    [Parameter(Mandatory=$true)]
    [String[]]$Servers,
    [String]$WorkingFolder
  )
 
 Import-DscResource -ModuleName PSDesiredStateConfiguration
 Import-DscResource -ModuleName xPSDesiredStateConfiguration

  Node $Servers
  { 

    Package InstallWin10ADK
    {

        DependsOn = "[xRemoteFile]DownloadWin10ADK"
        Name = "Windows Assessment and Deployment Kit - Windows 10"
        Path =  "$WorkingFolder\adksetup.exe"
        ProductId = ''
        Arguments = "/Features + /norestart /quiet /ceip off"
        Ensure = "Present"

    }

    LocalConfigurationManager 
    { 
        RebootNodeIfNeeded = $True 
    } 

    Package InstallMDT8443
    {
        
        DependsOn = "[xRemoteFile]DownloadMDT8443"
        Name = "Microsoft Deployment Toolkit (6.3.8443.1000)"
        Path =  "$WorkingFolder\MicrosoftDeploymentToolkit_x64.msi"
        ProductId = '{9547DE37-4A70-4194-97EA-ACC3E747254B}'
        Arguments = "/qn"
        Ensure = "Present"

    }

    LocalConfigurationManager 
    { 
        RebootNodeIfNeeded = $True 
    }

  } 
}

DeployMDT2013Lab -Servers localhost -OutputPath $WorkingFolder -WorkingFolder $WorkingFolder

Start-DscConfiguration -Path $WorkingFolder -wait -Verbose -Force -ErrorAction Stop