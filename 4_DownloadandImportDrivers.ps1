<# 
.SYNOPSIS 
Downloads drivers from pre-built CSV to a destination location of your choice and then will import them into MDT 
.DESCRIPTION 
The 4_DownloadAndImportDrivers.ps1 script will create a folder tree in the destination location of the drivers you would like to download. It will first unzip any ZIP files and then import from that location using Andrew Barnes' Import-MDTDrivers.ps1 script. 
.PARAMETER RawDriverDownloadLocation 
The destination location you would like the raw folder structure of your drivers to be created in.
.PARAMETER CSVPath
Path to the CSV that is used to download all of your drivers. Format for CSV should be (OS,Architecture,Make,Model,DownloadURL) 
.EXAMPLE 
.\4_DownloadAndImportDrivers.ps1 -RawDriverDownloadLocation "\\myremoteserver\drivershare\" -CSVPath C:\My\DriversCSV.csv
This will download all of the drivers in your CSV the location of \\myremoteserver\drivershare\$OS_$Architecture\$Make\$Model and then import all of those drivers into MDT replicating the same folder structure in MDT. 
.NOTES 
Author: Micah Rairdon 
Date: 14 December 2016 
Last Modified: 14 December 2016 
#> 
Param (
    [Parameter(Mandatory=$true)]
    [String]$RawDriverDownloadLocation,
    [Parameter(Mandatory=$true)] 
    [String]$CSVPath
)

$Drivers = Import-Csv $CSVPath



foreach ($Driver in $Drivers) { 

    $Make = $Driver.Make
    $Model = $Driver.Model
    $OS = $Driver.OS
    $Arch = $Driver.Architecture

    switch ($OS) {

        "WinPE" {
            $DestinationFolder = "$RawDriverDownloadLocation\$($OS)_$($Arch)"
            break
        }

        default { 
            $DestinationFolder = "$RawDriverDownloadLocation\$OS`_$Arch\$Make\$Model\"
        }

    }

    if(Test-Path $DestinationFolder) { 
        Write-Host "Skipping downloading $OS $Arch $Make $Model as folder already exists"
    } else {
        New-Item $DestinationFolder -ItemType directory -Force 
        Start-BitsTransfer -Asynchronous -Source $Driver.'Driver Download' -Destination $DestinationFolder -TransferType Download
    }
}

while (Get-BitsTransfer | where { @( "Transferred","FatalError" ) -notcontains $_.JobState }) {

    $DownloadsRemaining = Get-BitsTransfer | where { @( "Transferred","Error" ) -notcontains $_.JobState }

    Write-Progress -Activity "Downloading drivers: $($DownloadsRemaining.count) remaining"

    Start-Sleep -Seconds 30

}

Get-BitsTransfer | Complete-BitsTransfer

#Unzipping any drivers that came as a ZIP instead of a CAB
Get-ChildItem -Path $RawDriverDownloadLocation -Filter *.zip -Recurse | foreach { 
        Expand-Archive -Path $_.FullName -DestinationPath $_.DirectoryName -Force -ErrorAction Stop
        Remove-Item -Path $_.FullName
    }

..\UtilityFunctions\Import-MDTDrivers.ps1 -DriverPath $RawDriverDownloadLocation