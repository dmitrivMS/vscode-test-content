<#
.SYNOPSIS
    Sets up WSL with Ubuntu, a desktop environment, and installs VS Code.

.DESCRIPTION
    Installs WSL if not present, installs or resets an Ubuntu image, installs desktop packages,
    initializes the desktop environment, downloads VS Code for a given commit, and installs it
    using the specified package type (snap, deb, or rpm).

.PARAMETER Quality
    The VS Code quality: stable, insider, or exploration.

.PARAMETER Commit
    The commit ID to download.

.PARAMETER PackageType
    The package format to download and install: snap, deb, or rpm.

.PARAMETER Clean
    When specified, unregisters and reinstalls the Ubuntu distro from scratch.

.EXAMPLE
    .\install-wsl.ps1 -Commit abc123def
    .\install-wsl.ps1 -Quality stable -Commit abc123def -PackageType deb
    .\install-wsl.ps1 -Commit abc123def -PackageType rpm -Clean
#>

param(
    [ValidateSet('stable', 'insider', 'exploration')]
    [string]$Quality = 'insider',

    [Parameter(Mandatory = $true)]
    [string]$Commit,

    [ValidateSet('snap', 'deb', 'rpm')]
    [string]$PackageType = 'snap',

    [switch]$Clean
)

$ErrorActionPreference = 'Stop'

# Install WSL if not installed
Write-Host "Checking WSL installation..."
$wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -ErrorAction SilentlyContinue
if (-not $wslFeature -or $wslFeature.State -ne 'Enabled') {
    Write-Host "Installing WSL..."
    wsl --install --no-distribution
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to install WSL (exit code $LASTEXITCODE). A reboot may be required."
        exit 1
    }
    Write-Host "WSL installed. A reboot may be required before continuing."
}
else {
    Write-Host "WSL is already installed."
}

# Ensure WSL 2 is the default version
wsl --set-default-version 2 2>$null

# Install or reset Ubuntu
Write-Host "Setting up Ubuntu in WSL..."
$distroName = 'Ubuntu'

$installed = wsl --list --quiet 2>$null | ForEach-Object { $_.Trim("`0") } | Where-Object { $_ -eq $distroName }
if ($installed -and $Clean) {
    Write-Host "Unregistering existing $distroName to reset..."
    wsl --unregister $distroName
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to unregister $distroName."
        exit 1
    }
    $installed = $null
}

if (-not $installed) {
    Write-Host "Installing $distroName..."
    wsl --install -d $distroName --no-launch
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to install $distroName (exit code $LASTEXITCODE)."
        exit 1
    }

    Write-Host "Initializing $distroName..."
    wsl -d $distroName -- bash -c "echo 'Ubuntu initialized successfully'"
} else {
    Write-Host "$distroName is already installed. Use -Clean to reset."
}

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to initialize $distroName."
    exit 1
}

# Install desktop packages
Write-Host "Checking desktop packages in Ubuntu..."
$desktopPackages = @(
    'ubuntu-desktop-minimal'
    'snapd'
    'dbus-x11'
    'x11-xserver-utils'
    'xdg-utils'
)
$packageList = $desktopPackages -join ' '

$missing = wsl -d $distroName -- bash -c "dpkg -s $packageList 2>&1 | grep -c 'is not installed'"
if ($missing -gt 0) {
    Write-Host "Installing desktop packages in Ubuntu..."
    wsl -d $distroName -u root -- bash -c "export DEBIAN_FRONTEND=noninteractive; apt-get update && apt-get install -y $packageList"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to install desktop packages."
        exit 1
    }
} else {
    Write-Host "Desktop packages are already installed."
}

# Initialize desktop environment
Write-Host "Initializing desktop environment..."
$initScript = @(
    'mkdir -p /var/run/dbus'
    'dbus-daemon --system --fork 2>/dev/null || true'
    'if ! pgrep -x snapd > /dev/null; then mkdir -p /run/snapd; snapd & sleep 2; fi'
    'grep -q /snap/bin /etc/environment 2>/dev/null || echo ''PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"'' > /etc/environment'
    'echo "Desktop environment initialized."'
) -join '; '
wsl -d $distroName -u root -- bash -c "$initScript"
if ($LASTEXITCODE -ne 0) {
    Write-Warning "Desktop environment initialization had issues, continuing..."
}

# Download VS Code package
$qualitySuffix = switch ($Quality) {
    'stable'      { '' }
    'insider'     { '-insider' }
    'exploration' { '-exploration' }
}

$platform = switch ($PackageType) {
    'snap' { 'linux-snap-x64' }
    'deb'  { 'linux-deb-x64' }
    'rpm'  { 'linux-rpm-x64' }
}
$extension = $PackageType
$filename = "code$qualitySuffix-$Commit.$extension"
$downloadUrl = "https://update.code.visualstudio.com/commit:$Commit/$platform/$Quality"

Write-Host "Downloading VS Code $PackageType package..."
wsl -d $distroName -- bash -c "curl -fSL -o /tmp/$filename '$downloadUrl'"
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to download VS Code from $downloadUrl"
    exit 1
}
Write-Host "Downloaded to /tmp/$filename"

# Install package
Write-Host "Installing VS Code via $PackageType..."
switch ($PackageType) {
    'snap' {
        wsl -d $distroName -u root -- bash -c "snap install /tmp/$filename --dangerous --classic"
    }
    'deb' {
        wsl -d $distroName -u root -- bash -c "apt install -y /tmp/$filename"
    }
    'rpm' {
        wsl -d $distroName -u root -- bash -c "apt-get install -y alien && alien -i /tmp/$filename"
    }
}
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to install VS Code via $PackageType."
    exit 1
}

Write-Host "VS Code ($Quality) installed successfully via $PackageType in WSL Ubuntu."
Write-Host "Done."