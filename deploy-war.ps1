<#
.Synopsis
Deploy WAR file to remote Tomcat env.

.Description
This script takes in a single argument, the path to the warfile to deploy and 

.Notes
Requires cURL

Last Updated:   11132014
Version:        1.0
Author:         nic seltzer

.Outputs
Pushes a WAR file, via the Tomcat API to a remote host and redeploys that WAR.
#>

param (
    [string]$Context = "ROOT",
    [Parameter(Mandatory=$True)]
    [string]$TargetHostname,
    [int]$TargetPort =  8080,
    [string]$TomcatUser = "admin",
    [string]$TomcatPassword = "admin",
    [string]$BuildTargetDirectory = "C:\Tomcat7\build\target\",
    [boolean]$Undeploy = $false
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
    $CurlCommand = "& " + $CurlExecutable + ' "' + $TomcatURL + '/manager/serverinfo"'
    Write-Host "Executing $CurlCommand ..."
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

function Deploy-Context {
    if ($TomcatVersion -eq 6) {
        $APIPath = "/manager/deploy?path="
    } elseif ($TomcatVersion -eq 7) {
        $APIPath = "/manager/text/deploy?path="
    }
    # Don't forget the ampersand, its absence makes the Powershell diety, Invoke-Expression, cranky.
    $CurlCommand = "& " + $CurlExecutable + " --upload-file " + $BuildTargetDirectory + $WarFile `
        + ' "' + $TomcatURL + $APIPath + $Context + '&update=true"'
    Write-Host "Executing $CurlCommand ..."
    Invoke-Expression $CurlCommand
}

function Undeploy-Context {
    if ($TomcatVersion -eq 6) {
        $APIPath = "/manager/undeploy?path="
    } elseif ($TomcatVersion -eq 7) {
        $APIPath = "/manager/text/undeploy?path="
    }
    # Don't forget the ampersand, its absence makes the Powershell diety, Invoke-Expression, cranky.
    $CurlCommand = "& " + $CurlExecutable + ' "' + $TomcatURL + $APIPath + $Context + `
        '&update=true"'
    Write-Host "Executing $CurlCommand ..."
    Invoke-Expression $CurlCommand
}

function main() {
    if ($Undeploy) {
        Undeploy-Context
    } else {
        Deploy-Context
    }
}

# Kick out the epic...
main
