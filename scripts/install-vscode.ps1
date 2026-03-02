<#
.SYNOPSIS
    Downloads and installs Visual Studio Code silently.

.DESCRIPTION
    Downloads a VS Code installer by commit ID and installs it silently with all options enabled
    (desktop shortcut, context menu entries, file associations, PATH, Start Menu).

.PARAMETER Quality
    The VS Code quality: stable, insider, or exploration.

.PARAMETER InstallType
    The type of installation: user or system.

.PARAMETER Commit
    The commit ID to download.

.EXAMPLE
    .\install-vscode.ps1 -Commit abc123def
    .\install-vscode.ps1 -Quality stable -InstallType system -Commit abc123def
#>

param(
    [ValidateSet('stable', 'insider', 'exploration')]
    [string]$Quality = 'insider',

    [ValidateSet('user', 'system')]
    [string]$InstallType = 'user',

    [Parameter(Mandatory = $true)]
    [string]$Commit
)

$ErrorActionPreference = 'Stop'

# Build download URL
$arch = if ([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture -eq [System.Runtime.InteropServices.Architecture]::Arm64) { 'arm64' } else { 'x64' }
$platform = if ($InstallType -eq 'user') { "win32-$arch-user" } else { "win32-$arch" }
$downloadUrl = "https://update.code.visualstudio.com/commit:$Commit/$platform/$Quality"

# Determine installer filename
$qualitySuffix = switch ($Quality) {
    'stable'      { '' }
    'insider'     { '-insider' }
    'exploration' { '-exploration' }
}
$installerName = "VSCodeSetup-$arch$qualitySuffix-$Commit.exe"
$installerPath = Join-Path $env:TEMP $installerName

# Download installer
if (Test-Path $installerPath) {
    Write-Host "Installer already exists: $installerPath. Skipping download."
} else {
    Write-Host "Downloading VS Code ($Quality, $InstallType) from:"
    Write-Host "  $downloadUrl"
    Write-Host "  -> $installerPath"

    try {
        curl.exe -fSL -o $installerPath $downloadUrl
        if ($LASTEXITCODE -ne 0) { throw "curl exited with code $LASTEXITCODE" }
    } catch {
        Write-Error "Failed to download installer: $_"
        exit 1
    }

    if (-not (Test-Path $installerPath)) {
        Write-Error "Installer not found after download."
        exit 1
    }
}

Write-Host "Download complete. Installing silently..."

# Inno Setup tasks: enable all options
$tasks = @(
    'desktopicon'
    'quicklaunchicon'
    'addcontextmenufiles'
    'addcontextmenufolders'
    'associatewithfiles'
    'addtopath'
    '!runcode'
)
$mergedTasks = $tasks -join ','

$setupArgs = @(
    '/VERYSILENT'
    '/NORESTART'
    '/MERGETASKS={0}' -f $mergedTasks
    '/LOG="{0}"' -f (Join-Path $env:TEMP "vscode-install-$Quality.log")
)

$process = Start-Process -FilePath $installerPath -ArgumentList $setupArgs -Wait -PassThru
if ($process.ExitCode -eq 0) {
    Write-Host "VS Code ($Quality, $InstallType) installed successfully."
} else {
    Write-Warning "Installer exited with code $($process.ExitCode). Check log: $env:TEMP\vscode-install-$Quality.log"
}

Write-Host "Done."