<#
.SYNOPSIS
    Uninstalls Visual Studio Code from Windows.

.DESCRIPTION
    Uninstalls VS Code based on the install type: system (system-wide), user (per-user), or all (both).

.PARAMETER InstallType
    The type of installation to uninstall: system, user, or all.

.PARAMETER Clean
    When specified, performs a full cleanup: removes VS Code directories (user data, extensions, server, caches),
    temp files, desktop shortcuts, Start Menu entries, taskbar pins, file associations, registry keys,
    and Start Menu Recommended entries.

.EXAMPLE
    .\uninstall-vscode.ps1 -InstallType user
    .\uninstall-vscode.ps1 -InstallType system
    .\uninstall-vscode.ps1 -InstallType all -Clean
#>

param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('system', 'user', 'all')]
    [string]$InstallType = 'all',

    [switch]$Clean
)

$ErrorActionPreference = 'Stop'

function Find-UninstallEntries {
    param([string]$RegistryPath)

    $entries = @()
    if (Test-Path $RegistryPath) {
        Get-ChildItem $RegistryPath | ForEach-Object {
            $displayName = $_.GetValue('DisplayName')
            if ($displayName -and $displayName -match 'Microsoft Visual Studio Code') {
                $entries += [PSCustomObject]@{
                    DisplayName    = $displayName
                    UninstallString = $_.GetValue('UninstallString')
                    QuietUninstall  = $_.GetValue('QuietUninstallString')
                }
            }
        }
    }
    return $entries
}

function Uninstall-VSCodeEntries {
    param([PSCustomObject[]]$Entries, [string]$Label)

    if ($Entries.Count -eq 0) {
        Write-Host "No $Label VS Code installation found."
        return
    }

    foreach ($entry in $Entries) {
        Write-Host "Uninstalling $Label install: $($entry.DisplayName)..."

        $uninstallCmd = if ($entry.QuietUninstall) { $entry.QuietUninstall } else { $entry.UninstallString }
        if (-not $uninstallCmd) {
            Write-Warning "No uninstall command found for $($entry.DisplayName). Skipping."
            continue
        }

        # Append /SILENT if not already a quiet uninstall (Inno Setup convention)
        if (-not $entry.QuietUninstall) {
            $uninstallCmd = "$uninstallCmd /SILENT"
        }

        # Parse executable and arguments
        if ($uninstallCmd -match '^"([^"]+)"\s*(.*)$') {
            $exe = $Matches[1]
            $args = $Matches[2]
        } elseif ($uninstallCmd -match '^(\S+)\s*(.*)$') {
            $exe = $Matches[1]
            $args = $Matches[2]
        } else {
            Write-Warning "Could not parse uninstall command: $uninstallCmd"
            continue
        }

        if (-not (Test-Path $exe)) {
            Write-Warning "Uninstaller not found: $exe. Skipping."
            continue
        }

        $process = Start-Process -FilePath $exe -ArgumentList $args -Wait -PassThru
        if ($process.ExitCode -eq 0) {
            Write-Host "Successfully uninstalled: $($entry.DisplayName)"
        } else {
            Write-Warning "Uninstaller exited with code $($process.ExitCode) for $($entry.DisplayName)"
        }
    }
}

# Kill running VS Code process trees
$codeProcesses = Get-Process -Name 'Code', 'Code - Insiders', 'Code - Exploration' -ErrorAction SilentlyContinue
if ($codeProcesses) {
    Write-Host "Stopping VS Code process trees..."
    foreach ($proc in $codeProcesses) {
        # Kill child processes first, then the parent
        Get-CimInstance Win32_Process | Where-Object { $_.ParentProcessId -eq $proc.Id } | ForEach-Object {
            Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
        }
        Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
    }
    Start-Sleep -Seconds 2
}

# System installs are in HKLM
$systemEntries = @()
$systemEntries += Find-UninstallEntries 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'
$systemEntries += Find-UninstallEntries 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall'

# User (per-user) installs are in HKCU
$userEntries = Find-UninstallEntries 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'

switch ($InstallType) {
    'system' {
        Uninstall-VSCodeEntries -Entries $systemEntries -Label 'system'
    }
    'user' {
        Uninstall-VSCodeEntries -Entries $userEntries -Label 'user'
    }
    'all' {
        Uninstall-VSCodeEntries -Entries $systemEntries -Label 'system'
        Uninstall-VSCodeEntries -Entries $userEntries -Label 'user'
    }
}

if ($Clean) {
    Write-Host "`nCleaning up VS Code directories..."

    $dirsToRemove = @(
        # User data
        "$env:APPDATA\Code"
        "$env:APPDATA\Code - Insiders"
        "$env:APPDATA\Code - Exploration"
        # Extensions
        "$env:USERPROFILE\.vscode"
        "$env:USERPROFILE\.vscode-insiders"
        "$env:USERPROFILE\.vscode-exploration"
        # VS Code Server (remote / WSL)
        "$env:USERPROFILE\.vscode-server"
        "$env:USERPROFILE\.vscode-server-insiders"
        "$env:USERPROFILE\.vscode-server-exploration"
        # Local state / cache (user setup targets)
        "$env:LOCALAPPDATA\Programs\Microsoft VS Code"
        "$env:LOCALAPPDATA\Programs\Microsoft VS Code Insiders"
        "$env:LOCALAPPDATA\Programs\Microsoft VS Code Exploration"
        # System setup targets
        "${env:ProgramFiles}\Microsoft VS Code"
        "${env:ProgramFiles}\Microsoft VS Code Insiders"
        "${env:ProgramFiles}\Microsoft VS Code Exploration"
        "${env:ProgramFiles(x86)}\Microsoft VS Code"
        "${env:ProgramFiles(x86)}\Microsoft VS Code Insiders"
        "${env:ProgramFiles(x86)}\Microsoft VS Code Exploration"
        # Caches
        "$env:TEMP\vscode-typescript"
    )

    foreach ($dir in $dirsToRemove) {
        if (Test-Path $dir) {
            Write-Host "  Removing $dir"
            Remove-Item -Path $dir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    # Clean temp files and folders
    Write-Host "Cleaning temp files..."
    Remove-Item -Path "$env:TEMP\vscode-inno-updater*" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:TEMP\Setup Log *.txt" -Force -ErrorAction SilentlyContinue
    Get-ChildItem -Path $env:TEMP -Directory -Filter 'vscode-*' -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Host "  Removing $($_.FullName)"
        Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
    }

    # Clean desktop shortcuts
    Write-Host "Cleaning desktop shortcuts..."
    $desktopPaths = @(
        [Environment]::GetFolderPath('Desktop')
        [Environment]::GetFolderPath('CommonDesktopDirectory')
    )
    foreach ($desktop in $desktopPaths) {
        Get-ChildItem -Path $desktop -Filter 'Visual Studio Code*.lnk' -ErrorAction SilentlyContinue | ForEach-Object {
            Write-Host "  Removing $($_.FullName)"
            Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue
        }
    }

    # Clean Start Menu entries
    Write-Host "Cleaning Start Menu entries..."
    $startMenuPaths = @(
        [Environment]::GetFolderPath('Programs')
        [Environment]::GetFolderPath('CommonPrograms')
    )
    foreach ($startMenu in $startMenuPaths) {
        # Remove shortcuts
        Get-ChildItem -Path $startMenu -Filter 'Visual Studio Code*.lnk' -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
            Write-Host "  Removing $($_.FullName)"
            Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue
        }
        # Remove VS Code folders (e.g. "Visual Studio Code", "Visual Studio Code Insiders")
        Get-ChildItem -Path $startMenu -Directory -ErrorAction SilentlyContinue | Where-Object {
            $_.Name -match '^Visual Studio Code'
        } | ForEach-Object {
            Write-Host "  Removing $($_.FullName)"
            Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    # Clean Start Menu "Recommended" entries
    Write-Host "Cleaning Start Menu Recommended entries..."
    $featureUsagePaths = @(
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FeatureUsage\AppSwitched'
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FeatureUsage\AppLaunch'
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FeatureUsage\ShowJumpView'
    )
    foreach ($path in $featureUsagePaths) {
        if (Test-Path $path) {
            $props = Get-ItemProperty $path -ErrorAction SilentlyContinue
            $props.PSObject.Properties | Where-Object { $_.Name -match 'Code' } | ForEach-Object {
                Write-Host "  Removing $($_.Name) from $path"
                Remove-ItemProperty -Path $path -Name $_.Name -ErrorAction SilentlyContinue
            }
        }
    }
    # Remove recent .lnk files referencing VS Code
    $recentPath = [Environment]::GetFolderPath('Recent')
    if (Test-Path $recentPath) {
        Get-ChildItem -Path $recentPath -Filter '*.lnk' -ErrorAction SilentlyContinue | Where-Object {
            $_.Name -match 'Visual Studio Code|Code - Insiders|Code - Exploration'
        } | ForEach-Object {
            Write-Host "  Removing $($_.FullName)"
            Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue
        }
    }
    # Restart Start Menu to clear cached recommendations
    Stop-Process -Name 'StartMenuExperienceHost' -Force -ErrorAction SilentlyContinue

    # Clean taskbar pins
    Write-Host "Cleaning taskbar pins..."
    $taskbarPath = "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
    if (Test-Path $taskbarPath) {
        Get-ChildItem -Path $taskbarPath -Filter 'Visual Studio Code*.lnk' -ErrorAction SilentlyContinue | ForEach-Object {
            Write-Host "  Removing $($_.FullName)"
            Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue
        }
    }

    # Clean file associations
    Write-Host "Cleaning file associations..."
    $vsCodeProgIds = @(
        'Applications\Code.exe'
        'Applications\Code - Insiders.exe'
        'Applications\Code - Exploration.exe'
    )
    foreach ($progId in $vsCodeProgIds) {
        $classPath = "HKCU:\SOFTWARE\Classes\$progId"
        if (Test-Path $classPath) {
            Write-Host "  Removing $classPath"
            Remove-Item -Path $classPath -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    # Remove UserChoice keys that point to VS Code
    # Uses Win32 API (RegDeleteKey) to bypass the protected ACLs on UserChoice keys
    $regUtilCode = @'
        [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        private static extern int RegOpenKeyEx(UIntPtr hKey, string subKey, int ulOptions, int samDesired, out UIntPtr hkResult);

        [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        private static extern uint RegDeleteKey(UIntPtr hKey, string subKey);

        private static readonly UIntPtr HKCU = (UIntPtr)0x80000001u;

        public static void DeleteKey(string subKey) {
            UIntPtr hKey = UIntPtr.Zero;
            RegOpenKeyEx(HKCU, subKey, 0, 0x20019, out hKey);
            RegDeleteKey(HKCU, subKey);
        }
'@
    try { Add-Type -MemberDefinition $regUtilCode -Namespace RegistryUtil -Name UserChoice } catch {}

    Write-Host "Cleaning UserChoice file associations..."
    $fileExtsPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts'
    if (Test-Path $fileExtsPath) {
        Get-ChildItem $fileExtsPath -ErrorAction SilentlyContinue | ForEach-Object {
            $userChoice = Join-Path $_.PSPath 'UserChoice'
            if (Test-Path $userChoice) {
                $progId = (Get-ItemProperty $userChoice -ErrorAction SilentlyContinue).ProgId
                if ($progId -and $progId -match 'Code') {
                    Write-Host "  Resetting file association for $($_.PSChildName)"
                    $regKey = "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$($_.PSChildName)\UserChoice"
                    [RegistryUtil.UserChoice]::DeleteKey($regKey)
                }
            }
        }
    }

    # Clean MuiCache entries referencing VS Code
    Write-Host "Cleaning MuiCache entries..."
    $muiCacheKeys = @(
        'Registry::HKEY_CLASSES_ROOT\Local Settings\Software\Microsoft\Windows\Shell\MuiCache'
        'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache'
    )
    foreach ($muiCacheKey in $muiCacheKeys) {
        if (Test-Path $muiCacheKey) {
            $props = Get-ItemProperty $muiCacheKey -ErrorAction SilentlyContinue
            $props.PSObject.Properties | Where-Object { $_.Name -match 'VS Code|Code - Insiders|Code - Exploration|Microsoft VS Code' } | ForEach-Object {
                Write-Host "  Removing $($_.Name) from $muiCacheKey"
                Remove-ItemProperty -Path $muiCacheKey -Name $_.Name -ErrorAction SilentlyContinue
            }
        }
    }

    # Clean ApplicationAssociationToasts entries referencing VS Code
    Write-Host "Cleaning ApplicationAssociationToasts entries..."
    $toastsKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts'
    if (Test-Path $toastsKey) {
        $props = Get-ItemProperty $toastsKey -ErrorAction SilentlyContinue
        $props.PSObject.Properties | Where-Object { $_.Name -match 'VSCode|Code - Insiders|Code - Exploration' } | ForEach-Object {
            Write-Host "  Removing $($_.Name)"
            Remove-ItemProperty -Path $toastsKey -Name $_.Name -ErrorAction SilentlyContinue
        }
    }

    # Clean Compatibility Assistant Store entries referencing VS Code
    Write-Host "Cleaning Compatibility Assistant Store entries..."
    $compatStorePath = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Compatibility Assistant\Store'
    if (Test-Path $compatStorePath) {
        $props = Get-ItemProperty $compatStorePath -ErrorAction SilentlyContinue
        $props.PSObject.Properties | Where-Object { $_.Name -match 'VS Code|VSCode' } | ForEach-Object {
            Write-Host "  Removing $($_.Name)"
            Remove-ItemProperty -Path $compatStorePath -Name $_.Name -ErrorAction SilentlyContinue
        }
    }

    # Clean VS Code registry keys
    Write-Host "Cleaning VS Code registry keys..."
    $regKeysToRemove = @(
        # Uninstall entries (HKCU)
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{771FD6B0-FA20-440A-A002-3B3BAC16DC50}_is1'
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{217B4C08-948D-4276-BFBB-BEE930AE5A2C}_is1'
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{26F4A15E-E392-4887-8C09-7BC55712UCD2}_is1'
        # VS Code app settings
        'HKCU:\SOFTWARE\VSCode'
        'HKCU:\SOFTWARE\VSCodeInsiders'
        'HKCU:\SOFTWARE\VSCodeExploration'
        # VS Code classes
        'HKCU:\SOFTWARE\Classes\vscode'
        'HKCU:\SOFTWARE\Classes\vscode-insiders'
        'HKCU:\SOFTWARE\Classes\vscode-exploration'
        'HKCU:\SOFTWARE\Classes\.vscode'
        'HKCU:\SOFTWARE\Classes\.vscode-workspace'
        # Context menu (Open with Code)
        'HKCU:\SOFTWARE\Classes\*\shell\VSCode'
        'HKCU:\SOFTWARE\Classes\Directory\shell\VSCode'
        'HKCU:\SOFTWARE\Classes\Directory\Background\shell\VSCode'
        # HKLM equivalents (system installs)
        'HKLM:\SOFTWARE\Classes\vscode'
        'HKLM:\SOFTWARE\Classes\vscode-insiders'
        'HKLM:\SOFTWARE\Classes\vscode-exploration'
        'HKLM:\SOFTWARE\Classes\*\shell\VSCode'
        'HKLM:\SOFTWARE\Classes\Directory\shell\VSCode'
        'HKLM:\SOFTWARE\Classes\Directory\Background\shell\VSCode'
    )
    foreach ($regKey in $regKeysToRemove) {
        if (Test-Path -LiteralPath $regKey) {
            Write-Host "  Removing $regKey"
            Remove-Item -LiteralPath $regKey -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    Write-Host "Cleanup complete."
}

Write-Host "`nDone."
