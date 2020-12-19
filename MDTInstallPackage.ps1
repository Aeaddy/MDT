
Write-progress -Activity "Installing the latest version of PowerShell to support advanced DSC and easy installation of PowerShell Modules"
Write-Verbose "Installing the latest version of PowerShell to support advanced DSC and easy installation of PowerShell Modules"

Choco Install PowerShell
if(Test-PendingReboot){ Invoke-Reboot }

$WorkingFolder = "D:\MDTConfiguration"
$DeploymentShare = "D:\DeploymentShare"

if(-not ( (Get-Module -ListAvailable | select -ExpandProperty name) -contains "xPSDesiredStateConfiguration") ) {
    Install-Module xPSDesiredStateConfiguration -Force
}

if(-not ( (Get-Module -ListAvailable | select -ExpandProperty name) -contains "xPSDesiredStateConfiguration") ) {
    Install-Module xSMBShare -Force
}

Write-Progress -Activity "Running the initial preparation of the server"
Write-Verbose "Running the initial preparation of the server"
# Steps done in this script
#  1. Download Windows 10 ISO from source location
#  2. Download Windows ADK from Microsoft
#  3. Download Windows MDT Installer
. $WorkingFolder\MainScripts\1_InitialPreparation.ps1

if(Test-PendingReboot){ Invoke-Reboot }

Write-Progress -Activity "Running the initial installation of the MDT Server"
Write-Verbose "Running the initial installation of the MDT Server"
# Steps done in this script
#  1. Install Windows ADK
#  2. Install Microsoft Deployment Toolkit
. $WorkingFolder\MainScripts\2_InitialMDTInstallation.ps1

if(Test-PendingReboot){ Invoke-Reboot }

Write-Progress -Activity "Running the initial configuration of the MDT Server"
Write-Verbose "Running the initial configuration of the MDT Server"
# Steps done in this script
#  1. Extracting ISO and importing into MDT
#  2. Loading in a good customsettings.ini template for easier customization
#  3. Creating a good standardized folder structure in MDT
. $WorkingFolder\MainScripts\3_InitialMDTConfiguration.ps1

if(Test-PendingReboot){ Invoke-Reboot }

Write-Progress -Activity "Downloading and importing drivers to MDT"
Write-Verbose "Downloading and importing drivers to MDT"
# Steps done in this script
#  1. Download all drivers in CSV to raw driver folder structure location (CSV format = OS,Architecture,Make,Model,DownloadURL)
#  2. Import drivers from folder structure into MDT
. $WorkingFolder\MainScripts\4_DownloadandImportDrivers.ps1 -RawDriverDownloadLocation \\nahollap544\Imaging\Drivers\ -CSVPath $WorkingFolder\DriverURLS.csv

if(Test-PendingReboot){ Invoke-Reboot }

Write-Progress -Activity "Performing final configuration steps of MDT server"
Write-Verbose "Performing final configuration steps of MDT server"
# Steps done in this script
#  1. Create task sequences
#  2. Create selection profiles
. $WorkingFolder\MainScripts\5_FinalMDTConfiguration.ps1

if(Test-PendingReboot){ Invoke-Reboot }


Write-Progress -Activity "Installing and configuring WSUS"
Write-Verbose "Installing and configuring WSUS"
. $WorkingFolder\MainScripts\6_WSUSSetupandConfig.ps1

if(Test-PendingReboot){ Invoke-Reboot }

Write-Progress -Activity "Running inital configuration of DFS on MDT server"
Write-Verbose "Running inital configuration of DFS on MDT server"
. $WorkingFolder\MainScripts\7_DFSInitialConfiguration.ps1

if(Test-PendingReboot){ Invoke-Reboot }

Write-Progress -Activity "Running the initial seeding of the deployment share to remote sites"
Write-Verbose "Running the initial seeding of the deployment share to remote sites"
. $WorkingFolder\MainScripts\8_DFSInitialSeeding.ps1

if(Test-PendingReboot){ Invoke-Reboot }

Write-Progress -Activity "Running the DFS replication configuration"
Write-Verbose "Running the DFS replication configuration"
. $WorkingFolder\MainScripts\9_DFSReplicationConfiguration.ps1

if(Test-PendingReboot){ Invoke-Reboot }