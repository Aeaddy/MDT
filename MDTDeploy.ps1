#requires -Version 5.0

$WorkingFolder = "D:\MDTConfiguration"
$DeploymentShare = "D:\DeploymentShare"

$InstalledModules = Get-Module -ListAvailable

$RequiredModules = "xPSDesiredStateConfiguration"

Install-Module xPSDesiredStateConfiguration

# Getting Windows 10 ISO
if (-not (Test-Path -Path "$WorkingFolder\SW_DVD5_WIN_ENT_10_1607_64BIT_English_MLF_X21-07102.ISO") ) {
    Start-BitsTransfer -Source "\\nahollap544\apps\Source\Haworth\EITcesTools\ISO's\SW_DVD5_WIN_ENT_10_1607_64BIT_English_MLF_X21-07102.ISO" -Destination $WorkingFolder -ErrorAction Stop
}


Configuration DeployMDT2013Lab    
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

    # http://en.community.dell.com/techcenter/enterprise-client/w/wiki/2065.dell-command-deploy-driver-packs-for-enterprise-client-os-deployment
    xRemoteFile DownloadDellDriverWinPECAB
    {
        URI = "http://downloads.dell.com/FOLDER03652534M/1/WINPE10.0-DRIVERS-A03-2K3RC.CAB"
        DestinationPath = "$WorkingFolder\Drivers\WINPE10.0-DRIVERS-A03-2K3RC.CAB"
        MatchSource = $False
    }

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

    Package RemoveMDT2013
    {

        Name = "Microsoft Deployment Toolkit 2013 Update 2 (6.3.8330.1000)"
        Path =  "$WorkingFolder\MicrosoftDeploymentToolkit2013_x64.msi"
        ProductId = '{F172B6C7-45DD-4C22-A5BF-1B2C084CADEF}'
        Ensure = "Absent"

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

#region Extracting ISOs and importing into MDT

New-Item -Path "$DeploymentShare" -ItemType directory
New-SmbShare -Name "DeploymentShare$" -Path "$DeploymentShare" -FullAccess Administrators
Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
new-PSDrive -Name "DS001" -PSProvider "MDTProvider" -Root "$DeploymentShare" -Description "MDT Deployment Share" -NetworkPath "\\$($env:COMPUTERNAME)\DeploymentShare$" -Verbose | add-MDTPersistentDrive -Verbose
new-item -path "DS001:\Operating Systems" -enable "True" -Name "ISO No Updates" -Comments "This folder holds WIM files created from the ISOs. These have no Windows updates installed and no 3rd party software." -ItemType "folder" -Verbose


$MountResult = Mount-DiskImage -ImagePath "$WorkingFolder\SW_DVD5_WIN_ENT_10_1607_64BIT_English_MLF_X21-07102.ISO" -PassThru
$DriveLetter = ($MountResult | Get-Volume).DriveLetter

Write-Output "Importing Windows 10 Image"
import-mdtoperatingsystem -path "DS001:\Operating Systems\ISO No Updates" -SourcePath "$DriveLetter`:\" -DestinationFolder "Windows 10 x64" -Verbose

Dismount-DiskImage -ImagePath "$WorkingFolder\SW_DVD5_WIN_ENT_10_1607_64BIT_English_MLF_X21-07102.ISO"

#endregion



@'
[Settings]
Priority=Default
Properties=MyCustomProperty
[Default]
' // Credentials for connecting to network share
UserID=
UserDomain=
UserPassword=
' // Wizard Pages
SkipWizard=NO
SkipAppsOnUpgrade=NO
SkipDeploymentType=NO
SkipComputerName=NO
SkipDomainMembership=NO
' // OSDComputerName = 
' // and
' // JoinWorkgroup = 
' // or
' // JoinDomain = 
' // DomainAdmin = 
SkipUserData=NO
' // UDDir = 
' // UDShare = 
' // UserDataLocation = 
SkipComputerBackup=NO
' // BackupDir = 
' // BackupShare = 
' // ComputerBackupLocation = 
SkipTaskSequence=NO
' // TaskSequenceID="Task Sequence ID Here"
SkipProductKey=NO
' // ProductKey = 
' // Or
' // OverrideProductKey = 
' // Or
' // If using Volume license, no Property is required
SkipPackageDisplay=NO
' // LanguagePacks = 
SkipLocaleSelection=NO
' // KeyboardLocale = 
' // UserLocale = 
' // UILanguage = 
SkipTimeZone=NO
' // TimeZone = 
' // TimeZoneName = 
SkipApplications=NO
' // Applications
SkipAdminPassword=NO
' // AdminPassword
SkipCapture=NO
' // ComputerBackupLocation = 
SkipBitLocker=NO
' // BDEDriveLetter = 
' // BDEDriveSize = 
' // BDEInstall = 
' // BDEInstallSuppress = 
' // BDERecoveryKey = 
' // TPMOwnerPassword = 
' // OSDBitLockerStartupKeyDrive = 
' // OSDBitLockerWaitForEncryption = 
SkipSummary=NO
SkipFinalSummary=NO
SkipCredentials=NO
SkipRoles=NO
' // OSRoles
' // OSRoleServices
' // OSFeatures
SkipBDDWelcome=NO
SkipAdminAccounts=NO
' // Administrators = 
'@ | Out-File $DeploymentShare\Control\CustomSettings.ini -Encoding ASCII

update-MDTDeploymentShare -path "DS001:" -Verbose


#region MDT Folders

    new-item -path "DS001:\Operating Systems" `
        -enable "True" `
        -Name "Base OS" `
        -Comments "This will hold base WIM images. Fully patched but no scripts embedded or software installed" `
        -ItemType "folder" -Verbose

    new-item -path "DS001:\Operating Systems" `
        -enable "True" `
        -Name "Custom OS" `
        -Comments "This will hold customized WIM images. They may contain special software or scripts" `
        -ItemType "folder" -Verbose

    new-item -path "DS001:\Out-Of-Box Drivers" `
        -enable "True" `
        -Name "WinPE x64" `
        -Comments "This will hold network and mass storage drivers for the WinPE 10 x64 environment" `
        -ItemType "folder" -Verbose

    new-item -path "DS001:\Out-Of-Box Drivers" `
        -enable "True" `
        -Name "Windows 10 x64" `
        -Comments "This will hold network and mass storage drivers for the Windows 10 x64 environment" `
        -ItemType "folder" -Verbose

    new-item -path "DS001:\Packages" `
        -enable "True" `
        -Name "Language Packs" `
        -Comments "This is intended to hold language packs for the operatings systems" `
        -ItemType "folder" -Verbose

    new-item -path "DS001:\Packages\Language Packs" `
        -enable "True" `
        -Name "Windows 10" `
        -Comments "This is intended to hold language packs for Windows 10" `
        -ItemType "folder" -Verbose

    new-item -path "DS001:\Packages" `
        -enable "True" `
        -Name "OS Patches" `
        -Comments "This is intended to hold OS Patches for all OSes" `
        -ItemType "folder" -Verbose

    new-item -path "DS001:\Packages\OS Patches" `
        -enable "True" `
        -Name "Windows 10" `
        -Comments "This is intended to hold OS Patches for Windows 10" `
        -ItemType "folder" -Verbose

    new-item -path "DS001:\Task Sequences" `
        -enable "True" `
        -Name "Windows 10" `
        -Comments "This is intended to hold the various task sequences for Windows 10 images" `
        -ItemType "folder" -Verbose


$Drivers = Import-Csv D:\MDTConfiguration\DriverURLs.csv



foreach ($Driver in ( $Drivers | where { $_."Driver Download" -ne "Not Supported" }) ) { 

    $Make = $Driver.Make
    $Model = $Driver.Model

    Write-Host "Downloading driver to $DestinationFolder"

    switch ($Make) {

        "WinPE x64" {
            $OS = "WinPE x64"
            $DestinationFolder = "$WorkingFolder\Drivers\$OS"
            break
        }

        default { 
            $OS = "Windows 10 x64"
            $DestinationFolder = "$WorkingFolder\Drivers\$OS\$Make\$Model\"
        }

    }

    if(-not (Test-Path $DestinationFolder) ) { New-Item $DestinationFolder -ItemType directory -Force }

    #Start-BitsTransfer -Asynchronous -Source $Driver.'Driver Download' -Destination $DestinationFolder -TransferType Download

}

while (Get-BitsTransfer | where { @( "Transferred","FatalError" ) -notcontains $_.JobState }) {

    $DownloadsRemaining = Get-BitsTransfer | where { @( "Transferred","Error" ) -notcontains $_.JobState }

    Write-Progress -Activity "Downloading drivers: $($DownloadsRemaining.count) remaining"

    Start-Sleep -Seconds 30

}

Get-BitsTransfer | Complete-BitsTransfer

Get-ChildItem -Path $WorkingFolder\Drivers -Filter *.zip -Recurse | foreach { 
        Expand-Archive -Path $_.FullName -DestinationPath $_.DirectoryName -Force -ErrorAction Stop
        Remove-Item -Path $_.FullName
    }

.\Import-MDTDrivers.ps1 -DriverPath $WorkingFolder\Drivers