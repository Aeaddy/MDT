Configuration PrepareMDTServer    
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
   
    File Windows10ISO
    {
        Ensure = "Present"  # You can also set Ensure to "Absent"
        Type = "File" # Default is "File".
        SourcePath = "\\nahollap544\apps\Source\Haworth\EITcesTools\ISO's\SW_DVD5_WIN_ENT_10_1607_64BIT_English_MLF_X21-07102.ISO"
        DestinationPath = "$WorkingFolder\SW_DVD5_WIN_ENT_10_1607_64BIT_English_MLF_X21-07102.ISO"    
    }

    xRemoteFile DownloadMDT8443
    {
        URI = "https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x64.msi"
        DestinationPath = "$WorkingFolder\MicrosoftDeploymentToolkit_x64.msi"
        MatchSource = $False
    }

    xRemoteFile DownloadWin10ADK
    {
        URI = "http://download.microsoft.com/download/8/1/9/8197FEB9-FABE-48FD-A537-7D8709586715/adk/adksetup.exe"
        DestinationPath = "$WorkingFolder\adksetup.exe"
        MatchSource = $False
    }

}

PrepareMDTServer -Servers localhost -OutputPath $WorkingFolder -WorkingFolder $WorkingFolder

Start-DscConfiguration -Path $WorkingFolder -wait -Verbose -Force -ErrorAction Stop