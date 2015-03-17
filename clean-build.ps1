<#
.Synopsis
Cleans out the following items:
    C:\Tomcat7\build\target\* if "all" is specified as the Context
    - or -
    C:\Tomcat7\build\target\$Context.* where $Context is defined via argument; defaults to "ROOT"

.Description
This script creates a WAR file based on the name of an originating project folder.


.Notes
There is a requirement that 7-Zip be installed to the C:\Program Files\7-Zip\ directory.

Last Updated:   11132014
Version:        1.0
Author:         nic seltzer

.Outputs
None.
#>

param(
    [string]$Context = "ROOT",
    [string]$BuildTargetDirectory = "C:\Tomcat7\build\target\"
)

function cleanBuildTarget($BuildTargetDirectory, $Context) {
    Remove-Item "$BuildTargetDirectory$Context*"
}

function cleanBuildTargetAll($BuildTargetDirectory) {
    Remove-Item "$BuildTargetDirectory*"
}

function main() {
    if ($Context.ToLower() -eq "all") {
        cleanBuildTargetAll $BuildTargetDirectory
    } else {
    cleanBuildTarget $BuildTargetDirectory $Context
    }
}

# Kick out the epic...
main
