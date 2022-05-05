#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [Parameter(Mandatory = $True)]
    [string]$SiteName,
    [Parameter(Mandatory = $True)]
    [string]$Context
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Path $PSScriptRoot -Parent
Push-Location -Path $projectRoot
try {
    . (Join-Path -Path $projectRoot -ChildPath '.azure-pipelines' -AdditionalChildPath 'utilities.ps1')

    # Setting up environment variables
    Write-LogSection -Content 'Setting up environment variables...'
    if (Test-AzureDevOpsEnvironment) {
        $Env:COMMIT_REF = $Env:BUILD_SOURCEVERSION
    }
    else {
        Write-LogCommand -Content '$Env:COMMIT_REF = & git rev-parse HEAD'
        $Env:COMMIT_REF = & git rev-parse HEAD
        Assert-LastExitCodeSuccess -LastExecutableName 'git'
    }

    # Building with Netlify CLI
    Write-LogSection -Content 'Building site preview...'
    Write-LogCommand -Content "netlify build --context $Context"
    & netlify build --context $Context
    Assert-LastExitCodeSuccess -LastExecutableName 'netlify'

    # Embedding version
    Write-LogSection -Content 'Embedding version...'
    "${Env:COMMIT_REF}" | Out-File -FilePath ./build/version.txt
    Write-LogInfo -Content 'Embedded version.'
}
catch {
    if (($null -ne $_.ErrorDetails) -and ($null -ne $_.ErrorDetails.Message)) {
        Write-LogError -Content $_.ErrorDetails.Message
    }
    elseif (($null -ne $_.Exception) -and ($null -ne $_.Exception.Message)) {
        Write-LogError -Content $_.Exception.Message
    }
    else {
        Write-LogError -Content $_
    }

    exit 1
}
finally {
    Pop-Location
}
