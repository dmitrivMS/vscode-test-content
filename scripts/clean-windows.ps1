<#
.SYNOPSIS
    Uninstalls specified Windows apps (user and system provisioned).

.EXAMPLE
    .\clean-windows.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = 'Stop'

$apps = @(
    'Microsoft.M365Companions'                # Calendar, Files
    'Microsoft.WindowsCamera'                 # Camera
    'Clipchamp.Clipchamp'                     # Microsoft Clipchamp
    'Microsoft.CompanyPortal'                 # Company Portal
    'Microsoft.WindowsFeedbackHub'            # Feedback Hub
    'Microsoft.XboxGamingOverlay'             # Game Bar
    'Microsoft.GetHelp'                       # Get Help
    'Microsoft.MicrosoftOfficeHub'            # Microsoft 365 Copilot
    'Microsoft.BingSearch'                    # Microsoft Bing
    'Microsoft.WindowsStore'                  # Microsoft Store
    'Microsoft.Todos'                         # Microsoft To Do
    'Microsoft.BingNews'                      # News
    'Microsoft.YourPhone'                     # Phone Link
    'MicrosoftCorporationII.QuickAssist'      # Quick Assist
    'Microsoft.MicrosoftSolitaireCollection'  # Solitaire & Casual Games
    'Microsoft.WindowsSoundRecorder'          # Sound Recorder
    'Microsoft.StartExperiencesApp'           # Start Experiences App
    'Microsoft.MicrosoftStickyNotes'          # Sticky Notes
    'Microsoft.Office.OneNote.MemoryPreview'  # Sticky Notes (new)
    'Microsoft.BingWeather'                   # Weather
    'MicrosoftWindows.Client.WebExperience'   # Widgets
    'Microsoft.WidgetsPlatformRuntime'        # Widgets Platform Runtime
    'Microsoft.GamingApp'                     # Xbox
    'Microsoft.XboxSpeechToTextOverlay'       # Xbox Speech To Text
    'Microsoft.Xbox.TCUI'                     # Xbox TCUI
    'Microsoft.XboxIdentityProvider'          # Xbox Identity Provider
)

foreach ($app in $apps) {
    # Remove per-user packages for all users
    $packages = Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue
    if ($packages) {
        foreach ($pkg in $packages) {
            Write-Host "Removing package: $($pkg.PackageFullName)"
            try {
                Remove-AppxPackage -Package $pkg.PackageFullName -AllUsers -ErrorAction Stop
            } catch {
                Write-Warning "Could not remove $($pkg.Name): $($_.Exception.Message)"
            }
        }
    } else {
        Write-Host "Not installed: $app"
    }

    # Deprovision so the app won't reinstall for new user accounts
    $provisioned = Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -eq $app }
    if ($provisioned) {
        foreach ($prov in $provisioned) {
            Write-Host "Deprovisioning: $($prov.PackageName)"
            Remove-AppxProvisionedPackage -Online -PackageName $prov.PackageName
        }
    }
}

# People (PeopleExperienceHost) and Get Started (Client.CBS) are system-signed
# and can't be removed. Disable them via Group Policy registry keys.
foreach ($sysPkg in @('Microsoft.Windows.PeopleExperienceHost', 'MicrosoftWindows.Client.CBS')) {
    $prov = Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -eq $sysPkg }
    if ($prov) {
        foreach ($p in $prov) {
            Write-Host "Deprovisioning: $($p.PackageName)"
            Remove-AppxProvisionedPackage -Online -PackageName $p.PackageName -ErrorAction SilentlyContinue
        }
    }
}
Write-Host 'Disabling Get Started and People via registry policy...'
$regPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent'
if (-not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }
Set-ItemProperty -Path $regPath -Name 'DisableWindowsSpotlightOnSettings' -Value 1 -Type DWord
Set-ItemProperty -Path $regPath -Name 'DisableWindowsConsumerFeatures' -Value 1 -Type DWord
Write-Host 'Get Started disabled via policy.'

# Prevent specific Appx packages from being reinstalled by Windows Update or
# feature upgrades. Writing an empty key under the Deprovisioned store tells
# the deployment engine the package was intentionally removed.
Write-Host 'Marking packages as deprovisioned to block reinstall...'
$deprovRoot = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned'
foreach ($familyName in @(
    'Microsoft.CompanyPortal_8wekyb3d8bbwe'
    'Microsoft.WindowsFeedbackHub_8wekyb3d8bbwe'
)) {
    $keyPath = Join-Path $deprovRoot $familyName
    if (-not (Test-Path $keyPath)) {
        New-Item -Path $keyPath -Force | Out-Null
        Write-Host "Marked deprovisioned: $familyName"
    } else {
        Write-Host "Already deprovisioned: $familyName"
    }
}

# Disable Feedback Hub via Data Collection policy (prevents prompts too)
$dataCollPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'
if (-not (Test-Path $dataCollPath)) { New-Item -Path $dataCollPath -Force | Out-Null }
Set-ItemProperty -Path $dataCollPath -Name 'DoNotShowFeedbackNotifications' -Value 1 -Type DWord
Write-Host 'Feedback notifications disabled via policy.'

# Block Remote Help from being silently reinstalled by Intune/MDM
$remoteHelpPolicy = 'HKLM:\SOFTWARE\Policies\Microsoft\RemoteHelp'
if (-not (Test-Path $remoteHelpPolicy)) { New-Item -Path $remoteHelpPolicy -Force | Out-Null }
Set-ItemProperty -Path $remoteHelpPolicy -Name 'DisableRemoteHelp' -Value 1 -Type DWord
Write-Host 'Remote Help disabled via policy.'

# Remote Help is an MSI application, not an Appx package.
# Query registry instead of Win32_Product (which is extremely slow).
$uninstallPaths = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
)
$remoteHelp = Get-ItemProperty $uninstallPaths -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -eq 'Remote Help' } |
    Select-Object -First 1
if ($remoteHelp) {
    $guid = $remoteHelp.PSChildName
    Write-Host "Uninstalling MSI: Remote Help ($guid)"
    $process = Start-Process -FilePath 'msiexec.exe' `
        -ArgumentList "/x $guid /qn /norestart" `
        -Wait -PassThru
    if ($process.ExitCode -eq 0) {
        Write-Host 'Successfully uninstalled Remote Help'
    } elseif ($process.ExitCode -eq 1605) {
        Write-Host 'Remote Help already uninstalled (orphaned registry entry)'
    } else {
        Write-Warning "Remote Help uninstall exited with code $($process.ExitCode)"
    }
} else {
    Write-Host 'Not installed: Remote Help'
}

# OneDrive has its own uninstaller
$oneDrivePaths = @(
    "$env:SystemRoot\System32\OneDriveSetup.exe"
    "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
    "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDriveSetup.exe"
)
$oneDriveSetup = $oneDrivePaths | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($oneDriveSetup) {
    Write-Host "Uninstalling OneDrive..."
    Stop-Process -Name OneDrive -Force -ErrorAction SilentlyContinue
    $process = Start-Process -FilePath $oneDriveSetup -ArgumentList '/uninstall' -Wait -PassThru
    if ($process.ExitCode -eq 0) {
        Write-Host 'Successfully uninstalled OneDrive'
    } else {
        Write-Warning "OneDrive uninstall exited with code $($process.ExitCode)"
    }
    # Clean up leftover folders
    @(
        "$env:LOCALAPPDATA\Microsoft\OneDrive"
        "$env:PROGRAMDATA\Microsoft OneDrive"
        "$env:USERPROFILE\OneDrive"
    ) | ForEach-Object {
        if (Test-Path $_) {
            Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "Removed: $_"
        }
    }
} else {
    Write-Host 'Not installed: OneDrive'
}

function Set-TaskbarLayout {
    Write-Host 'Configuring taskbar...'

    # Remove Search from taskbar (0 = hidden, 1 = icon, 2 = search box)
    $searchPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search'
    if (-not (Test-Path $searchPath)) { New-Item -Path $searchPath -Force | Out-Null }
    Set-ItemProperty -Path $searchPath -Name 'SearchboxTaskbarMode' -Value 0 -Type DWord

    # Remove Task View / Desktops button
    $explorerPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    Set-ItemProperty -Path $explorerPath -Name 'ShowTaskViewButton' -Value 0 -Type DWord

    # Align Start menu to the left (0 = left, 1 = center)
    Set-ItemProperty -Path $explorerPath -Name 'TaskbarAl' -Value 0 -Type DWord

    # Show seconds on the taskbar clock
    Set-ItemProperty -Path $explorerPath -Name 'ShowSecondsInSystemClock' -Value 1 -Type DWord

    # Add UTC clock via Additional Clocks (TimeZone index)
    $tzInfoPath = 'HKCU:\Control Panel\TimeDate\AdditionalClocks\1'
    if (-not (Test-Path $tzInfoPath)) { New-Item -Path $tzInfoPath -Force | Out-Null }
    Set-ItemProperty -Path $tzInfoPath -Name 'Enable' -Value 1 -Type DWord
    Set-ItemProperty -Path $tzInfoPath -Name 'TzRegKeyName' -Value 'UTC' -Type String
    Set-ItemProperty -Path $tzInfoPath -Name 'DisplayName' -Value 'UTC' -Type String

    # Disable all Windows notifications
    $pushPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications'
    if (-not (Test-Path $pushPath)) { New-Item -Path $pushPath -Force | Out-Null }
    Set-ItemProperty -Path $pushPath -Name 'ToastEnabled' -Value 0 -Type DWord

    $notifPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings'
    if (-not (Test-Path $notifPath)) { New-Item -Path $notifPath -Force | Out-Null }
    Set-ItemProperty -Path $notifPath -Name 'NOC_GLOBAL_SETTING_TOASTS_ENABLED' -Value 0 -Type DWord

    # Hide the notification bell icon from the taskbar
    Set-ItemProperty -Path $explorerPath -Name 'TaskbarBadges' -Value 0 -Type DWord

    # Disable notification center (action center) via policy
    $notifPolicyPath = 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer'
    if (-not (Test-Path $notifPolicyPath)) { New-Item -Path $notifPolicyPath -Force | Out-Null }
    Set-ItemProperty -Path $notifPolicyPath -Name 'DisableNotificationCenter' -Value 1 -Type DWord

    Write-Host 'Taskbar configured. Restarting Explorer...'
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Start-Process explorer
    Write-Host 'Taskbar layout applied.'
}

Set-TaskbarLayout

Write-Host 'Done.'
