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
        $Env:REACT_APP_BUILD = $Env:BUILD_SOURCEVERSION
    }
    else {
        Write-LogCommand -Content '$Env:REACT_APP_BUILD = & git rev-parse HEAD'
        $Env:REACT_APP_BUILD = & git rev-parse HEAD
        Assert-LastExitCodeSuccess -LastExecutableName 'git'
    }
    if ($Context -eq 'production') {
        $Env:PUBLIC_URL = '/app'
        if ($SiteName = 'test') {
            $Env:REACT_APP_MIXPANEL_TOKEN = '4b245bace4eed86ffdfa35efc3addf1d'
        }
        else {
            $Env:REACT_APP_MIXPANEL_TOKEN = '68db9194f229525012624f3cf368921f'
        }
    }
    if (($Context -eq 'deploy-preview') -or ($SiteName = 'test')) {
        $Env:REACT_APP_API_URL = 'https://app-api-testing.salad.io'
        $Env:REACT_APP_PAYPAL_URL = 'https://www.sandbox.paypal.com/connect/?flowEntry=static&client_id=AYjYnvjB968mKTIhMqUtLlNa8CJuF9rg_Q4m0Oym5gFvBkZEMPPoooXcG94OjSCjih7kI1_KM25EgfDs&response_type=code&scope=openid%20email%20https%3A%2F%2Furi.paypal.com%2Fservices%2Fpaypalattributes&redirect_uri=https%253A%252F%252Fapp-api-testing.salad.io%252Fapi%252Fv2%252Fpaypal-account-callback'
        $Env:REACT_APP_PROHASHING_USERNAME = 'saladtest'
        $Env:REACT_APP_SEARCH_ENGINE = 'salad-rewards-test'
        $Env:REACT_APP_SEARCH_KEY = 'search-qced4ibef8m4s7xacm9hoqyk'
        $Env:REACT_APP_STRAPI_UPLOAD_URL = 'https://cms-api-testing.salad.io'
        $Env:REACT_APP_UNLEASH_API_KEY = 'zrujLzhnwVZkIOlS74oZZ0DK7ZXs3Ifo'
        $Env:REACT_APP_UNLEASH_URL = 'https://features-testing.salad.com/proxy'
    }

    # Building with Netlify CLI
    Write-LogSection -Content 'Building site with Netlify...'
    Write-LogCommand -Content "netlify build --context $Context"
    & netlify build --context $Context
    Assert-LastExitCodeSuccess -LastExecutableName 'netlify'

    Write-LogSection -Content 'Embedding version...'
    "${Env:REACT_APP_BUILD}" | Out-File -FilePath ./build/version.txt
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
