<#
.Synopsis
Takes input of a SRC file path and a DST file path. Outputs a single WAR file of the SRC file path.

.Description
This script creates a WAR file based on the name of an originating project folder.
-SourceDirectory <Source Directory>
-DestinationDirectory <DestinationDirection>

.Notes
There is a requirement that 7-Zip be installed to the C:\Program Files\7-Zip\ directory.

Last Updated:   11132014
Version:        1.0
Author:         nic seltzer

.Outputs
A WAR file to the specified directory
#>

param (
    [string]$SourceDirectory = "C:\Tomcat7\webapps\ROOT",
    [string]$DestinationDirectory = "C:\Tomcat7\build\target"
)

$WARName = Split-Path $SourceDirectory -Leaf
$DateTime = Get-Date -UFormat "%Y%m%d%H%M"

function New-WAR($SourceDirectory, $DestinationDirectory) {
    $DestinationFile = $DestinationDirectory  + "\" + $WARName + ".war"
    if (Test-Path $DestinationFile) {
        $BackupName = $DestinationFile + ' ' + $DateTime
        If (Test-Path $BackupName) {
            Write-Host "Unable to create backup because a backup of the same name already exists."
            exit
        }
        Rename-Item $DestinationFile $BackupName
    }
    return $DestinationFile
}

function Compress-WAR($DestinationFile, $SourceDirectory) {
    # Don't forget the ampersand, its absence makes the Powershell diety, Invoke-Expression, cranky.
    $CompressionCommand = '&"C:\Program Files\7-Zip\7z" a -tzip ' + $DestinationFile + ' ' `
    + $SourceDirectory + '\*'
    Write-Host "Executing $CompressionCommand ..."
    Invoke-Expression $CompressionCommand
    If (Test-Path $DestinationFile) {
        return $True
    } else {
        return $False
    }
}

function main() {
    $DestinationFile = New-WAR -SourceDirectory $SourceDirectory `
    -DestinationDirectory $DestinationDirectory
    If (!(Compress-WAR $DestinationFile $SourceDirectory)) {
        Write-Host "Unable to generate the WAR file."
    }
}

# Kick out the epic...
main
