<#
.Synopsis
Takes in an input for "-Context".

.Description
This script reloads a user-specified context on-demand.

.Notes
Last Updated:   1113014
Version:        1.0
Author:         nic seltzer

.Outputs
None.
#>

param (
    [string]$Context = "ROOT",
    [string]$TargetHostname = "localhost",
    [int]$TargetPort =  8080,
    [string]$TomcatUser = "admin",
    [string]$TomcatPassword = "admin"
)

$CurlExecutable = '"C:\Program Files (x86)\Git\bin\curl.exe"'
$WarFile = $Context + ".war"

# Perform the comparison between ROOT and Context
if ($Context.ToLower().CompareTo("root") -eq 0) {
    $Context = "/"
} else {
    $Context = "/" + $Context
}

# Create tomcat URL
$TomcatURL = 'http://' + $TomcatUser + ":" + $TomcatPassword + "@" + $TargetHostname + ":" `
 + $TargetPort

function Get-TomcatVersion {
    $IsPathText = $null
    $CurlCommand = "& " + $CurlExecutable + ' "' + $TomcatURL + '/manager/serverinfo"'
    $CurlResults = Invoke-Expression $CurlCommand
    if (!($CurlResults.Contains("OK - Server info"))) {
        $CurlCommand = "& " + $CurlExecutable + ' "' + $TomcatURL + '/manager/text/serverinfo"'
        $CurlResults = Invoke-Expression $CurlCommand
        if (!($CurlResults.Contains("OK - Server info"))) {
            Write-Host "Failed to determine version."
            exit
        }
    }
    $Version = $CurlResults.Split(':')[2].Split('/')[1]
    try {
        # We just need the first number of the Tomcat Version
        $Version = $Version.Substring(0,1)
    } catch [Exception] {
        Write-Host "Failed to determine version."
        exit
    }
    return $Version
}

$TomcatVersion = Get-TomcatVersion

function Reload-Context {
    if ($TomcatVersion -eq 6) {
        $APIPath = "/manager/reload?path="
    } elseif ($TomcatVersion -eq 7) {
        $APIPath = "/manager/text/reload?path="
    }
    # Don't forget the ampersand, its absence makes the Powershell diety, Invoke-Expression, cranky.
    $CurlCommand = "& " + $CurlExecutable + ' "' + $TomcatURL + $APIPath + $Context + '"'
    Write-Host "Executing $CurlCommand ..."
    Invoke-Expression $CurlCommand
}

function main {
    Reload-Context
}

# Kick out the epic...
main
