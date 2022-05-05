#!/usr/bin/env pwsh
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Path $PSScriptRoot -Parent
Push-Location -Path $projectRoot
try {
    . (Join-Path -Path $projectRoot -ChildPath '.azure-pipelines' -AdditionalChildPath 'utilities.ps1')

    $buildDirectory = Join-Path -Path $projectRoot -ChildPath 'build'
    $srcDirectory = Join-Path -Path $projectRoot -ChildPath 'src'
    $zipFile = Join-Path -Path $srcDirectory -ChildPath 'latest.zip'

    # Verify Node.js and npm
    Write-LogSection -Content 'Verifying Node.js, npm, and Yarn...'

    $nodeVersion = Get-NodeVersion
    if ($null -eq $nodeVersion) {
        Write-Error -Message 'Node.js is not installed'
    }

    $nvmrcVersion = Get-NvmrcVersion
    if ($null -eq $nvmrcVersion -or 0 -ne (Compare-NodeVersion -FirstVersion $nodeVersion -SecondVersion $nvmrcVersion)) {
        Write-Error -Message "Node.js ${nvmrcVersion} is not installed (found ${nodeVersion})"
    }

    Write-LogInfo -Content "Node.js ${nodeVersion} is installed"

    $npmVersion = Get-NpmVersion
    if ($null -eq $npmVersion) {
        Write-Error -Message 'npm is not installed'
    }

    Write-LogInfo -Content "npm ${npmVersion} is installed"

    $yarnVersion = Get-YarnVersion
    if ($null -eq $yarnVersion) {
        Write-Error -Message 'Yarn is not installed'
    }

    Write-LogInfo -Content "Yarn ${yarnVersion} is installed"

    # Install dependencies
    Write-LogSection -Content 'Installing dependencies...'

    Write-LogCommand -Content 'yarn install'
    & yarn install
    Assert-LastExitCodeSuccess -LastExecutableName 'yarn'

    $netlifyVersion = $null
    & npm list netlify-cli --global --depth 0 | Out-Null
    if (0 -eq $LastExitCode) {
        $netlifyVersion = Get-NetlifyVersion
    }

    if ($null -eq $netlifyVersion) {
        Write-LogCommand -Content 'npm install --global netlify-cli'
        & npm install --global netlify-cli
        Assert-LastExitCodeSuccess -LastExecutableName 'npm'

        $netlifyVersion = Get-NetlifyVersion
        if ($null -eq $netlifyVersion) {
            Write-Error -Message 'Failed to install Netlify CLI'
        }
    }

    Write-LogInfo -Content "Netlify CLI ${netlifyVersion} is installed"

    # Clean
    Write-LogSection -Content 'Cleaning...'

    if (Test-Path -Path $buildDirectory) {
        Remove-Item -Path $buildDirectory -Recurse -Force
    }

    New-Item -ItemType Directory -Path $buildDirectory | Out-Null

    if (Test-Path -Path $zipFile) {
        Remove-Item -Path $zipFile -Force
    }
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
