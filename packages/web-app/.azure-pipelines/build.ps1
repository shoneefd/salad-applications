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
    if ($Context -eq 'production') {
        Write-LogInfo -Content 'Setting public url and mixpanel token.'
        $Env:PUBLIC_URL = '/login'
        if ($SiteName -eq 'test') {
            $Env:REACT_APP_MIXPANEL_TOKEN = '4b245bace4eed86ffdfa35efc3addf1d'
        }
        else {
            $Env:REACT_APP_MIXPANEL_TOKEN = '68db9194f229525012624f3cf368921f'
        }
    }
    else {
        $Env:PUBLIC_URL = ''
    }

    if (($Context -ne 'production') -or ($SiteName -eq 'test')) {
        Write-LogSection -Content 'Setting React API URL.'
        $Env:REACT_APP_API_URL = 'https://app-api-testing.salad.io'
    }

    # Building with Netlify CLI
    Write-LogSection -Content 'Building site preview...'
    Write-LogCommand -Content "netlify build --context $Context"
    & netlify build --context $Context
    Assert-LastExitCodeSuccess -LastExecutableName 'netlify'
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
